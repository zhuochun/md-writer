utils = require "./utils"

HEADING_REGEX   = /// ^\# {1,6} \ + .+$ ///g
REFERENCE_REGEX = /// \[? ([^\s\]]+) (?:\] | \]:)? ///

LIST_UL_REGEX   = /// ^ (\s*) ([*+-]) \s+ (.*) $ ///
LIST_OL_REGEX   = /// ^ (\s*) (\d+)\. \s+ (.*) $ ///
LIST_TL_REGEX   = /// ^ (\s*) (-\ \[[xX\ ]\]) \s+ (.*) $ ///

TABLE_COL_REGEX = ///  ([^\|]*?) \s* \| ///
TABLE_VAL_REGEX = /// (?:^|\|) ([^\|]+) ///g

class Commands
  trigger: (command) ->
    fn = command.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()
    @[fn]()

  insertNewLine: ->
    editor = atom.workspace.getActiveTextEditor()
    line = editor.lineTextForBufferRow(editor.getCursorBufferPosition().row)

    {replaceLine, value} = @_findNewLineValue(line)

    editor.selectToBeginningOfLine() if replaceLine
    editor.insertText(value)

  _findNewLineValue: (line) ->
    if matches = LIST_TL_REGEX.exec(line)
      value = "\n#{matches[1]}- [ ] "
    else if matches = LIST_UL_REGEX.exec(line)
      value = "\n#{matches[1]}#{matches[2]} "
    else if matches = LIST_OL_REGEX.exec(line)
      value = "\n#{matches[1]}#{parseInt(matches[2], 10) + 1}. "

    if matches && !matches[3]
      return replaceLine: true, value: matches[1] || "\n"
    else
      return replaceLine: false, value: value || "\n"

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

  formatTable: ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor.getSelectedText()
      editor.moveCursorToBeginningOfPreviousParagraph()
      editor.selectToBeginningOfNextParagraph()
    lines = editor.getSelectedText().split("\n")

    range = @_findTableRange(lines, editor.getSelectedBufferRange())
    values = @_parseTable(lines)

    editor.setSelectedBufferRange(range)
    editor.insertText(@_createTable(values))

  _findTableRange: (lines, {start, end}) ->
    head = lines.findIndex (line) -> line != ""
    tail = lines[..].reverse().findIndex (line) -> line != ""

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
