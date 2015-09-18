config = require "../config"
utils = require "../utils"

LIST_OL_REGEX = /// ^ (\s*) (\d+)\. \s* (.*) $ ///

module.exports =
class FormatText
  # action: correct-order-list-numbers, format-table
  constructor: (action) ->
    @action = action
    @editor = atom.workspace.getActiveTextEditor()

  trigger: (e) ->
    fn = @action.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()

    @editor.transact =>
      # current paragraph range could be undefined if the cursor is at an empty line
      paragraphRange = @editor.getCurrentParagraphBufferRange()

      range = @editor.getSelectedBufferRange()
      range = paragraphRange.union(range) if paragraphRange

      text = @editor.getTextInBufferRange(range)
      return if range.start.row == range.end.row || text.trim() == ""

      formattedText = @[fn](e, range, text.split("\n"))
      @editor.setTextInBufferRange(range, formattedText)

  correctOrderListNumbers: (e, range, lines) ->
    correctedLines = []

    indentStack = []
    orderStack = []
    for line, idx in lines
      if matches = LIST_OL_REGEX.exec(line)
        indent = matches[1]

        if indentStack.length == 0 || indent.length > indentStack[0].length # first ol/sub-ol match
          indentStack.unshift(indent)
          orderStack.unshift(1)
        else if indent.length < indentStack[0].length # end of a sub-ol match
          indentStack.shift()
          orderStack.shift()

          orderStack.unshift(orderStack.shift() + 1)
        else # same level ol match
          orderStack.unshift(orderStack.shift() + 1)

        correctedLines[idx] = "#{indentStack[0]}#{orderStack[0]}. #{matches[3]}"
      else
        correctedLines[idx] = line

    correctedLines.join("\n")

  formatTable: (e, range, lines) ->
    { rows, options } = @_parseTable(lines)

    table = []

    # table head
    table.push(utils.createTableRow(rows[0], options).trimRight())
    # table separator
    table.push(utils.createTableSeparator(options))
    # table body
    table.push(utils.createTableRow(row, options).trimRight()) for row in rows[1..]

    table.join("\n")

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
