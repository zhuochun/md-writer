config = require "../config"
utils = require "../utils"

LineMeta = require "../helpers/line-meta"

MAX_SKIP_EMPTY_LINE_ALLOWED = 5

module.exports =
class EditLine
  # action: insert-new-line, indent-list-line
  constructor: (action) ->
    @action = action
    @editor = atom.workspace.getActiveTextEditor()

  trigger: (e) ->
    fn = @action.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()

    @editor.transact =>
      @editor.getSelections().forEach (selection) =>
        @[fn](e, selection)

  insertNewLine: (e, selection) ->
    return e.abortKeyBinding() if @_isRangeSelection(selection)

    cursor = selection.getHeadBufferPosition()
    line = @editor.lineTextForBufferRow(cursor.row)

    # when cursor is at middle of line, do a normal insert line
    # unless inline continuation is enabled
    if cursor.column < line.length && !config.get("inlineNewLineContinuation")
      return e.abortKeyBinding()

    lineMeta = new LineMeta(line)
    if lineMeta.isContinuous()
      if lineMeta.isEmptyBody()
        @_insertNewlineWithoutContinuation(cursor)
      else
        @_insertNewlineWithContinuation(lineMeta.nextLine)
      return

    if utils.isTableRow(line)
      row = utils.parseTableRow(line)
      columnWidths = row.columnWidths.reduce((sum, i) -> sum + i)
      if columnWidths == 0
        @_insertNewlineWithoutTableColumns()
      else
        @_insertNewlineWithTableColumns(row)
      return

    return e.abortKeyBinding()

  _insertNewlineWithContinuation: (nextLine) ->
    @editor.insertText("\n#{nextLine}")

  _insertNewlineWithoutContinuation: (cursor) ->
    nextLine = "\n"

    currentIndentation = @editor.indentationForBufferRow(cursor.row)
    # if this is an indented empty list, we will go up lines and try to find
    # its parent's list prefix and use that if possible
    if currentIndentation > 0 && cursor.row > 1
      emptyLineSkipped = 0

      for row in [(cursor.row - 1)..0]
        line = @editor.lineTextForBufferRow(row)

        if line.trim() == "" # skip empty lines in case of list paragraphs
          break if emptyLineSkipped > MAX_SKIP_EMPTY_LINE_ALLOWED
          emptyLineSkipped += 1
        else # find parent with indentation = current indentation - 1
          indentation = @editor.indentationForBufferRow(row)
          continue if indentation >= currentIndentation
          nextLine = new LineMeta(line).nextLine if indentation == currentIndentation - 1 && LineMeta.isList(line)
          break

    @editor.selectToBeginningOfLine()
    @editor.insertText(nextLine)

  _insertNewlineWithoutTableColumns: ->
    @editor.selectToBeginningOfLine()
    @editor.insertText("\n")

  _insertNewlineWithTableColumns: (row) ->
    options =
      numOfColumns: Math.max(1, row.columns.length)
      extraPipes: row.extraPipes
      columnWidth: 1
      columnWidths: []
      alignment: config.get("tableAlignment")
      alignments: []

    newLine = utils.createTableRow([], options)
    @editor.insertText("\n#{newLine}")
    @editor.moveToBeginningOfLine()

  indentListLine: (e, selection) ->
    return e.abortKeyBinding() if @_isRangeSelection(selection)

    cursor = selection.getHeadBufferPosition()
    line = @editor.lineTextForBufferRow(cursor.row)
    lineMeta = new LineMeta(line)

    if lineMeta.isList("ol")
      line = "#{@editor.getTabText()}#{lineMeta.lineHead(lineMeta.defaultHead)}#{lineMeta.body}"
      @_replaceLine(selection, cursor.row, line)

    else if lineMeta.isList("ul")
      bullet = config.get("templateVariables.ulBullet#{@editor.indentationForBufferRow(cursor.row)+1}")
      bullet = bullet || config.get("templateVariables.ulBullet") || lineMeta.defaultHead

      line = "#{@editor.getTabText()}#{lineMeta.lineHead(bullet)}#{lineMeta.body}"
      @_replaceLine(selection, cursor.row, line)

    else if @_isAtLineBeginning(line, cursor.column) # indent on start of line
      selection.indent()
    else
      e.abortKeyBinding()

  _isRangeSelection: (selection) ->
    head = selection.getHeadBufferPosition()
    tail = selection.getTailBufferPosition()

    head.row != tail.row || head.column != tail.column

  _replaceLine: (selection, row, line) ->
    selection.cursor.setBufferPosition([row, 0])
    selection.selectToEndOfLine()
    selection.insertText(line)

  _isAtLineBeginning: (line, col) ->
    col == 0 || line.substring(0, col).trim() == ""
