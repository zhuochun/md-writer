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

    lineMeta = new LineMeta(line)
    # don't continue alpha OL if the line is unindented
    if lineMeta.isList("al") && !lineMeta.isIndented()
      return e.abortKeyBinding()

    if lineMeta.isContinuous()
      # when cursor is at middle of line, do a normal insert line
      # unless inline continuation is enabled
      if cursor.column < line.length && !config.get("inlineNewLineContinuation")
        return e.abortKeyBinding()

      if lineMeta.isEmptyBody()
        @_insertNewlineWithoutContinuation(cursor)
      else
        @_insertNewlineWithContinuation(lineMeta)
      return

    if @_isTableRow(cursor, line)
      row = utils.parseTableRow(line)
      columnWidths = row.columnWidths.reduce((sum, i) -> sum + i)
      if columnWidths == 0
        @_insertNewlineWithoutTableColumns()
      else
        @_insertNewlineWithTableColumns(row)
      return

    return e.abortKeyBinding()

  _insertNewlineWithContinuation: (lineMeta) ->
    nextLine = lineMeta.nextLine
    # don't continue numbers in OL
    if lineMeta.isList("ol") && !config.get("orderedNewLineNumberContinuation")
      nextLine = lineMeta.lineHead(lineMeta.defaultHead)

    @editor.insertText("\n#{nextLine}")

  _insertNewlineWithoutContinuation: (cursor) ->
    currentIndentation = @editor.indentationForBufferRow(cursor.row)

    nextLine = "\n"
    # if this is an list without indentation, or at beginning of the file
    if currentIndentation < 1 || cursor.row < 1
      @editor.selectToBeginningOfLine()
      @editor.insertText(nextLine)
      return

    emptyLineSkipped = 0
    # if this is an indented empty list, we will go up lines and try to find
    # its parent's list prefix and use that if possible
    for row in [(cursor.row - 1)..0]
      line = @editor.lineTextForBufferRow(row)

      if line.trim() == "" # skip empty lines in case of list paragraphs
        break if emptyLineSkipped > MAX_SKIP_EMPTY_LINE_ALLOWED
        emptyLineSkipped += 1
      else # find parent with indentation = current indentation - 1
        indentation = @editor.indentationForBufferRow(row)
        continue if indentation >= currentIndentation

        if indentation == currentIndentation - 1 && LineMeta.isList(line)
          lineMeta = new LineMeta(line)
          nextLine = lineMeta.nextLine unless lineMeta.isList("al") && !lineMeta.isIndented()
        break

    @editor.selectToBeginningOfLine()
    @editor.insertText(nextLine)

  _isTableRow: (cursor, line) ->
    return false if !config.get("tableNewLineContinuation")
    # first row or not a row
    return false if cursor.row < 1 || !utils.isTableRow(line)
    # case 0, at table separator, continue table row
    return true if utils.isTableSeparator(line)
    # case 1, at table row, previous line is a row, continue row
    return true if utils.isTableRow(@editor.lineTextForBufferRow(cursor.row-1))
    # else, at table head, previous line is not a row, do not continue row
    return false

  _insertNewlineWithoutTableColumns: ->
    @editor.selectLinesContainingCursors()
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
    @editor.moveToEndOfLine()
    @editor.insertText("\n#{newLine}")
    @editor.moveToBeginningOfLine()
    @editor.moveToNextWordBoundary() if options.extraPipes

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
    range = selection.cursor.getCurrentLineBufferRange()
    selection.setBufferRange(range)
    selection.insertText(line)

  _isAtLineBeginning: (line, col) ->
    col == 0 || line.substring(0, col).trim() == ""
