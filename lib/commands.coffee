config = require "./config"
utils = require "./utils"

LIST_TL_REGEX   = /// ^ (\s*) (-\ \[[xX\ ]\]) \s+ (.*) $ ///
LIST_UL_REGEX   = /// ^ (\s*) ([*+-]) \s+ (.*) $ ///
LIST_OL_REGEX   = /// ^ (\s*) (\d+)\. \s+ (.*) $ ///

class Commands
  trigger: (command) ->
    fn = command.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()
    @[fn]()

  insertNewLine: ->
    editor = atom.workspace.getActiveTextEditor()
    cursor = editor.getCursorBufferPosition()
    line = editor.lineTextForBufferRow(cursor.row)

    return editor.insertNewline() if cursor.column < line.length

    currentLine = @_findLineValue(line)

    if currentLine.isEmptyList
      @_insertNewLineAfterEmptyList(editor, cursor)
    else if currentLine.isList
      editor.insertText("\n#{currentLine.nextLine}")
    else
      editor.insertNewline()

  # if it is an indented empty list, we will go up lines and try to find
  # its parent's list prefix and use that instead
  _insertNewLineAfterEmptyList: (editor, cursor) ->
    indentation = editor.indentationForBufferRow(cursor.row)

    if indentation == 0
      nextLine = "\n"
    else
      for row in [(cursor.row - 1)..0]
        line = editor.lineTextForBufferRow(row)
        break unless @_isListLine(line)
        break if editor.indentationForBufferRow(row) == indentation - 1

      {nextLine} = @_findLineValue(line)

    editor.selectToBeginningOfLine()
    editor.insertText("#{nextLine}")

  _findLineValue: (line) ->
    if matches = LIST_TL_REGEX.exec(line)
      nextLine = "#{matches[1]}- [ ] "
    else if matches = LIST_UL_REGEX.exec(line)
      nextLine = "#{matches[1]}#{matches[2]} "
    else if matches = LIST_OL_REGEX.exec(line)
      nextLine = "#{matches[1]}#{parseInt(matches[2], 10) + 1}. "
    else
      nextLine = ""

    return {
      isList: !!matches,
      isEmptyList: matches && !matches[3],
      nextLine: nextLine
    }

  indentListLine: ->
    editor = atom.workspace.getActiveTextEditor()
    editor.getSelections().forEach (selection) =>
      head = selection.getHeadBufferPosition()
      tail = selection.getTailBufferPosition()

      # we only handle cursor specially, means no selection range
      if head.row == tail.row && head.column == tail.column
        line = editor.lineTextForBufferRow(head.row)

        if @_isListLine(line)
          selection.indentSelectedRows()
        else if @_isAtLineBeginning(line, head.column)
          selection.indent()
        else
          selection.insertText(" ") # convert tab to space
      else
        selection.indentSelectedRows()

  _isListLine: (line) ->
    [LIST_TL_REGEX, LIST_UL_REGEX, LIST_OL_REGEX].some (rgx) -> rgx.exec(line)

  _isAtLineBeginning: (line, col) ->
    col == 0 || line.substring(0, col).trim() == ""



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

    { rows, options } = @_parseTable(lines)
    table = @_createTable(rows, options)

    editor.setTextInBufferRange(range, table)

  # FIXME when at the end of file, without the extra end of line
  # the buffer range selected is not correct
  _findMinSelectedBufferRange: (lines, {start, end}) ->
    head = @_indexOfFirstNonEmptyLine(lines)
    tail = @_indexOfFirstNonEmptyLine(lines[..].reverse())

    return null if head == -1 || tail == -1 # no buffer range
    return [
      [start.row + head, 0]
      [end.row - tail, lines[lines.length - 1 - tail].length]
    ]

  _indexOfFirstNonEmptyLine: (lines) ->
    for line, i in lines
      return i if line.trim().length > 0
    return -1 # not found

  _parseTable: (lines) ->
    rows = []

    numOfColumns = 0
    extraPipes = config.get("tableExtraPipes")
    columnWidths = []
    alignments = []

    # parse table separator
    for line in lines
      continue unless utils.isTableSeparator(line)

      separator = utils.parseTableSeparator(line)

      numOfColumns = separator.columns.length
      extraPipes = extraPipes || separator.extraPipes
      columnWidths = separator.columnWidths
      alignments = separator.alignments

    # parse table content
    for line in lines
      continue if line.trim() == ""
      continue if utils.isTableSeparator(line)

      row = utils.parseTableRow(line)
      rows.push(row.columns)
      numOfColumns = Math.max(numOfColumns, row.columns.length)
      for columnWidth, i in row.columnWidths
        if !extraPipes && (i == 0 || i == numOfColumns - 1)
          columnWidth += 1
        else
          columnWidth += 2

        columnWidths[i] = Math.max(columnWidths[i] || 0, columnWidth)

    return {
      rows: rows
      options: {
        numOfColumns: numOfColumns
        extraPipes: extraPipes
        columnWidths: columnWidths
        alignment: config.get("tableAlignment")
        alignments: alignments
      }
    }

  _createTable: (rows, options) ->
    table = []

    # table head
    table.push(utils.createTableRow(rows[0], options))
    # table separator
    table.push(utils.createTableSeparator(options))
    # table body
    table.push(utils.createTableRow(row, options)) for row in rows[1..]

    table.join("\n")

module.exports = new Commands()
