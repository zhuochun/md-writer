utils = require "./utils"

HEADING_REGEX   = /// ^\# {1,6} \ + .+$ ///g
REFERENCE_REGEX = /// \[? ([^\s\]]+) (?:\] | \]:)? ///

LIST_TL_REGEX   = /// ^ (\s*) (-\ \[[xX\ ]\]) \s+ (.*) $ ///
LIST_UL_REGEX   = /// ^ (\s*) ([*+-]) \s+ (.*) $ ///
LIST_OL_REGEX   = /// ^ (\s*) (\d+)\. \s+ (.*) $ ///

TABLE_COL_REGEX = ///  ([^\|]*?) \s* \| ///
TABLE_VAL_REGEX = /// (?:^|\|) ([^\|]+) ///g

class Commands
  trigger: (command) ->
    fn = command.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()
    @[fn]()

  insertNewLine: ->
    editor = atom.workspace.getActiveTextEditor()
    cursor = editor.getCursorBufferPosition()

    # find potential replace line
    line = editor.lineTextForBufferRow(cursor.row)
    {replaceLine, value} = @_findNewLineValue(line)

    # hanlde outdent/list label for replace line
    indentation = editor.indentationForBufferRow(cursor.row)
    if replaceLine && indentation > 0
      for row in [(cursor.row - 1)..0]
        line = editor.lineTextForBufferRow(row)
        break unless @_isListLine(line)
        break if editor.indentationForBufferRow(row) == indentation - 1
      {value} = @_findNewLineValue(line)
    else value = "\n#{value}"

    # insert new line
    editor.selectToBeginningOfLine() if replaceLine
    editor.insertText(value || "\n")

  _findNewLineValue: (line) ->
    if matches = LIST_TL_REGEX.exec(line)
      value = "#{matches[1]}- [ ] "
    else if matches = LIST_UL_REGEX.exec(line)
      value = "#{matches[1]}#{matches[2]} "
    else if matches = LIST_OL_REGEX.exec(line)
      value = "#{matches[1]}#{parseInt(matches[2], 10) + 1}. "

    if matches && !matches[3]
      return replaceLine: true, value: matches[1]
    else
      return replaceLine: false, value: value || ""

  indentListLine: ->
    editor = atom.workspace.getActiveTextEditor()
    cursor = editor.getCursorBufferPosition()
    line = editor.lineTextForBufferRow(cursor.row)

    if @_isListLine(line)
      editor.indentSelectedRows()
    else if @_isAtLineBeginning(line, cursor.column)
      editor.indent()
    else
      editor.insertText(" ") # convert tab to space

  _isListLine: (line) ->
    [LIST_TL_REGEX, LIST_UL_REGEX, LIST_OL_REGEX].some (rgx) -> rgx.exec(line)

  _isAtLineBeginning: (line, col) ->
    col == 0 || line.substring(0, col).trim() == ""

  jumpToPreviousHeading: ->
    editor = atom.workspace.getActiveTextEditor()
    {row} = editor.getCursorBufferPosition()

    @_executeMoveToPreviousHeading(editor, [[0, 0], [row - 1, 0]])

  _executeMoveToPreviousHeading: (editor, range) ->
    found = false
    editor.buffer.backwardsScanInRange HEADING_REGEX, range, (match) ->
      found = true
      editor.setCursorBufferPosition(match.range.start)
      match.stop()
    return found

  jumpToNextHeading: ->
    editor = atom.workspace.getActiveTextEditor()
    curPosition = editor.getCursorBufferPosition()
    eofPosition = editor.getEofBufferPosition()

    range = [
      [curPosition.row + 1, 0]
      [eofPosition.row + 1, 0]
    ]
    return if @_executeMoveToNextHeading(editor, range)

    # back to top
    @_executeMoveToNextHeading(editor, [[0, 0], [eofPosition.row + 1, 0]])

  _executeMoveToNextHeading: (editor, range) ->
    found = false
    editor.buffer.scanInRange HEADING_REGEX, range, (match) ->
      found = true
      editor.setCursorBufferPosition(match.range.start)
      match.stop()
    return found

  jumpBetweenReferenceDefinition: ->
    editor = atom.workspace.getActiveTextEditor()
    cursor = editor.getCursorBufferPosition()

    key = editor.getSelectedText() || editor.getWordUnderCursor()
    key = utils.regexpEscape(REFERENCE_REGEX.exec(key)[1])

    editor.buffer.scan /// \[ #{key} \] ///g, (match) ->
      end = match.range.end
      if end.row != cursor.row
        editor.setCursorBufferPosition([end.row, end.column - 1])
        match.stop()

  jumpToNextTableCell: ->
    editor = atom.workspace.getActiveTextEditor()
    {row, column} = editor.getCursorBufferPosition()

    line = editor.lineTextForBufferRow(row)
    cell = line.indexOf("|", column)

    if cell == -1
      row += 1
      line = editor.lineTextForBufferRow(row)

    if utils.isTableSeparator(line)
      row += 1
      cell = -1
      line = editor.lineTextForBufferRow(row)

    cell = @_findNextTableCellIdx(line, cell + 1)
    editor.setCursorBufferPosition([row, cell])

  _findNextTableCellIdx: (line, column) ->
    if td = TABLE_COL_REGEX.exec(line[column..])
      column + td[1].length
    else
      line.length + 1

  correctOrderListNumbers: ->
    editor = atom.workspace.getActiveTextEditor()

    lines = @_getSelectedLines(editor)
    lines = @_correctOrderNumbers(lines)

    editor.insertText(lines.join("\n"))

  _correctOrderNumbers: (lines) ->
    correctedLines = []

    indent = -1
    nextOrder = -1
    for line, idx in lines
      correctedLines[idx] = line

      matches = LIST_OL_REGEX.exec(line)
      continue unless matches

      if indent < 0 # first ol match
        indent = matches[1].length
        nextOrder = parseInt(matches[2], 10) + 1
      else if matches[1].length == indent # rest of ol matches
        correctedLines[idx] = "#{matches[1]}#{nextOrder}. #{matches[3]}"
        nextOrder += 1

    return correctedLines

  _getSelectedLines: (editor) ->
    unless editor.getSelectedText()
      editor.moveToBeginningOfPreviousParagraph()
      editor.selectToBeginningOfNextParagraph()

    lines = editor.getSelectedText().split("\n")

  formatTable: ->
    editor = atom.workspace.getActiveTextEditor()

    lines = @_getSelectedLines(editor)
    range = @_findMinSelectedBufferRange(lines, editor.getSelectedBufferRange())
    return unless range

    values = @_parseTable(lines)
    table = @_createTable(values)

    editor.setTextInBufferRange(range, table)

  _indexOfFirstNonEmptyLine: (lines) ->
    for line, i in lines
      return i if line.trim().length > 0
    return -1 # not found

  _findMinSelectedBufferRange: (lines, {start, end}) ->
    head = @_indexOfFirstNonEmptyLine(lines)
    tail = @_indexOfFirstNonEmptyLine(lines[..].reverse())

    return null if head == -1 || tail == -1 # no buffer range
    return [
      [start.row + head, 0]
      [end.row - tail, lines[lines.length - 1 - tail].length]
    ]

  _parseTable: (lines) ->
    table = []
    maxes = []

    for line in lines
      continue if line.trim() == ""
      continue if utils.isTableSeparator(line)

      columns = line.split("|").map (col) -> col.trim()
      table.push(columns)

      for col, j in columns
        if maxes[j]?
          maxes[j] = col.length if col.length > maxes[j]
        else
          maxes[j] = col.length

    return table: table, maxes: maxes

  _createTable: ({table, maxes}) ->
    result = []

    # table head
    result.push @_createTableRow(table[0], maxes, " | ")
    # table head separators
    result.push maxes.map((n) -> '-'.repeat(n)).join("-|-")
    # table body
    result.push @_createTableRow(vals, maxes, " | ") for vals in table[1..]

    return result.join("\n")

  _createTableRow: (vals, widths, separator) ->
    vals.map((val, i) -> "#{val}#{' '.repeat(widths[i] - val.length)}")
        .join(separator)
        .trimRight() # remove trailing spaces

  openCheatSheet: ->
    packageDir = atom.packages.getLoadedPackage("markdown-writer").path
    cheatsheet = require("path").join packageDir, "CHEATSHEET.md"

    atom.workspace.open "markdown-preview://#{encodeURI(cheatsheet)}",
      split: 'right', searchAllPanes: true

module.exports = new Commands()
