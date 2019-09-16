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
        @editor.insertText("\n")
        @editor.insertText(lineMeta.indent)
        @editor.insertText(lineMeta.indentLineTabText())
        return

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
    # use default head and do not increase numbers in OL when disabled continuation
    if lineMeta.isList("ol") && !config.get("orderedNewLineNumberContinuation")
      nextLine = lineMeta.lineHead(lineMeta.defaultHead)

    @editor.insertText("\n#{nextLine}")

  _insertNewlineWithoutContinuation: (cursor) ->
    nextLine = "\n"

    currentIndentation = @editor.indentationForBufferRow(cursor.row)
    parentLineMeta = @_findListLineBackward(cursor.row, currentIndentation)
    nextLine = parentLineMeta.nextLine if parentLineMeta && !parentLineMeta.isList("al")

    @editor.selectToBeginningOfLine()
    @editor.insertText(nextLine)

  # when a list line is indented, we need to look backward (go up) lines to find
  # its parent list line if possible and use that line as reference for new indentation etc
  _findListLineBackward: (currentRow, currentIndentation) ->
    return if currentRow < 1 || currentIndentation <= 0

    emptyLineSkipped = 0
    for row in [(currentRow - 1)..0]
      line = @editor.lineTextForBufferRow(row)

      if line.trim() == "" # skip empty lines which could be list paragraphs
        return if emptyLineSkipped > MAX_SKIP_EMPTY_LINE_ALLOWED
        emptyLineSkipped += 1

      else # find parent list line
        indentation = @editor.indentationForBufferRow(row)
        continue if indentation >= currentIndentation # ignore larger indentation

        # handle case when the line is not a list line
        if indentation == 0
          return unless LineMeta.isList(line) # early stop on a paragraph
        else
          continue unless LineMeta.isList(line) # skip on a paragraph in a list

        lineMeta = new LineMeta(line)
        # calculate the expected indentation
        indentation = (lineMeta.indent.length + lineMeta.indentLineTabLength()) / @editor.getTabLength()
        # return iff the line is the immediate parent (within 1 indentation)
        if currentIndentation > indentation-1 && currentIndentation < indentation+1
          return lineMeta
        else
          return

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
    # don't care about non-list or alpha list
    lineMeta = new LineMeta(line)
    return e.abortKeyBinding() if !lineMeta.isList() || lineMeta.isList("al")

    currentIndentation = @editor.indentationForBufferRow(cursor.row) + 1 # add 1 to identify the parent list
    parentLineMeta = @_findListLineBackward(cursor.row, currentIndentation)
    return e.abortKeyBinding() unless parentLineMeta

    if lineMeta.isList("ol")
      newline = "#{parentLineMeta.indentLineTabText()}#{lineMeta.lineHead(lineMeta.defaultHead)}#{lineMeta.body}"
      newcursor = [cursor.row, cursor.column + newline.length - line.length]
      @_replaceLine(selection, newline, newcursor)
      return

    if lineMeta.isList("ul")
      bullet = config.get("templateVariables.ulBullet#{Math.round(currentIndentation)}")
      bullet = bullet || config.get("templateVariables.ulBullet") || lineMeta.defaultHead

      newline = "#{parentLineMeta.indentLineTabText()}#{lineMeta.lineHead(bullet)}#{lineMeta.body}"
      newcursor = [cursor.row, cursor.column + newline.length - line.length]
      @_replaceLine(selection, newline, newcursor)
      return

    e.abortKeyBinding() # unmatched line

  _isRangeSelection: (selection) ->
    head = selection.getHeadBufferPosition()
    tail = selection.getTailBufferPosition()

    head.row != tail.row || head.column != tail.column

  _replaceLine: (selection, line, cursor) ->
    range = selection.cursor.getCurrentLineBufferRange()
    selection.setBufferRange(range)
    selection.insertText(line)
    selection.cursor.setBufferPosition(cursor)

  _isAtLineBeginning: (line, col) ->
    col == 0 || line.substring(0, col).trim() == ""

  undentListLine: (e, selection) ->
    return e.abortKeyBinding() if @_isRangeSelection(selection)

    cursor = selection.getHeadBufferPosition()
    line = @editor.lineTextForBufferRow(cursor.row)
    # don't care about non-list or alpha list
    lineMeta = new LineMeta(line)
    return e.abortKeyBinding() if !lineMeta.isList() || lineMeta.isList("al")

    currentIndentation = @editor.indentationForBufferRow(cursor.row)
    return e.abortKeyBinding() if currentIndentation <= 0

    parentLineMeta = @_findListLineBackward(cursor.row, currentIndentation)
    if !parentLineMeta && lineMeta.isList("ul")
      bullet = config.get("templateVariables.ulBullet#{Math.round(currentIndentation-1)}")
      bullet = bullet || config.get("templateVariables.ulBullet") || lineMeta.defaultHead

      newline = "#{lineMeta.lineHead(bullet)}#{lineMeta.body}"
      newline = newline.substring(Math.min(lineMeta.indent.length, @editor.getTabLength())) # remove one indent
      newcursor = [cursor.row, Math.max(cursor.column + newline.length - line.length, 0)]
      @_replaceLine(selection, newline, newcursor)
      return
    # treat as normal undent if no parent found
    return e.abortKeyBinding() unless parentLineMeta

    if parentLineMeta.isList("ol")
      newline = "#{parentLineMeta.lineHead(parentLineMeta.defaultHead)}#{lineMeta.body}"
      newcursor = [cursor.row, Math.max(cursor.column + newline.length - line.length, 0)]
      @_replaceLine(selection, newline, newcursor)
      return

    if parentLineMeta.isList("ul")
      newline = "#{parentLineMeta.lineHead(parentLineMeta.head)}#{lineMeta.body}"
      newcursor = [cursor.row, Math.max(cursor.column + newline.length - line.length, 0)]
      @_replaceLine(selection, newline, newcursor)
      return

    e.abortKeyBinding()
