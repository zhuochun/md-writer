utils = require "../utils"

HEADING_REGEX   = /// ^\# {1,6} \ + .+$ ///
REFERENCE_REGEX = /// \[ ([^\[\]]+) (?:\]|\]:) ///
TABLE_COL_REGEX = /// ([^\|]*?) \s* \| ///

module.exports =
class JumpTo
  constructor: (command) ->
    @command = command
    @editor = atom.workspace.getActiveTextEditor()
    @cursor = @editor.getCursorBufferPosition()

  trigger: (e) ->
    fn = @command.replace(/-[a-z]/ig, (s) -> s[1].toUpperCase())
    range = @[fn]()

    if range
      @editor.setCursorBufferPosition(range)
    else
      e.abortKeyBinding()

  previousHeading: ->
    range = [[0, 0], [@cursor.row - 1, 0]]

    found = false
    @editor.buffer.backwardsScanInRange HEADING_REGEX, range, (match) ->
      found = match.range.start
      match.stop()
    return found

  nextHeading: ->
    eof = @editor.getEofBufferPosition()

    range =
      # find to end of file
      @_findNextHeading([[@cursor.row + 1, 0], [eof.row + 1, 0]]) ||
      # find around the top of file
      @_findNextHeading([[0, 0], [eof.row + 1, 0]])

    return range

  _findNextHeading: (range) ->
    found = false
    @editor.buffer.scanInRange HEADING_REGEX, range, (match) ->
      found = match.range.start
      match.stop()
    return found

  referenceDefinition: ->
    range = utils.getTextBufferRange(@editor, "link", selectBy: "currentLine")

    if link = utils.findLinkInRange(@editor, range)
      return false if !link.id # normal link
      return false if !link.linkRange || !link.definitionRange # orphan link

      if link.linkRange.start.row != @cursor.row && link.linkRange.end.row != @cursor.row
        return [link.linkRange.start.row, link.linkRange.start.column]
      else
        return [link.definitionRange.start.row, link.definitionRange.start.column]

    else
      selection = @editor.getTextInRange(range)
      return false unless selection

      link = REFERENCE_REGEX.exec(selection)
      return false unless link

      found = false
      @editor.buffer.scan /// \[ #{utils.escapeRegExp(link[1])} \] ///g, (match) =>
        if match.range.start.row != @cursor.row && match.range.end.row != @cursor.row
          found = [match.range.start.row, match.range.start.column]
          match.stop()
      return found

  nextTableCell: ->
    line = @editor.lineTextForBufferRow(@cursor.row)

    if utils.isTableRow(line) || utils.isTableSeparator(line)
      @_findNextTableCell(line, @cursor.row, @cursor.column)
    else
      false

  _findNextTableCell: (currentLine, row, column) ->
    # find the next column separator on current line
    column = currentLine.indexOf("|", column)

    # when at the last column of current line
    if column == -1 || column == currentLine.length - 1
      row += 1
      column = 0
      currentLine = @editor.lineTextForBufferRow(row)

    # when current line is table separator
    if utils.isTableSeparator(currentLine)
      row += 1
      column = 0
      currentLine = @editor.lineTextForBufferRow(row)

    # exceeds the row of current document
    return false if currentLine == undefined

    # skip the pipe
    if currentLine[column] == "|"
      column += 1
      currentLine = currentLine[column..]

    # find the correct cell column by length
    if td = TABLE_COL_REGEX.exec(currentLine)
      [row, column + td[1].length]
    else
      [row, column + currentLine.length]
