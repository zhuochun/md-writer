config = require "../config"
utils = require "../utils"
LineMeta = require "../helpers/line-meta"

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
      return if range.start.row == range.end.row

      text = @editor.getTextInBufferRange(range)
      return if text.trim() == ""

      text = text.split(/\r?\n/)
      formattedText = @[fn](e, range, text)
      @editor.setTextInBufferRange(range, formattedText) if formattedText

  correctOrderListNumbers: (e, range, lines) ->
    correctedLines = []

    indentStack = []
    orderStack = []
    for line, idx in lines
      lineMeta = new LineMeta(line)

      if lineMeta.isList("ol")
        indent = lineMeta.indent

        if indentStack.length == 0 || indent.length > indentStack[0].length # first ol/sub-ol match
          indentStack.unshift(indent)
          orderStack.unshift(lineMeta.defaultHead)
        else if indent.length < indentStack[0].length # end of a sub-ol match
          # pop out stack until we are back to the same indent stack
          while indentStack.length > 0 && indent.length != indentStack[0].length
            indentStack.shift()
            orderStack.shift()

          if orderStack.length == 0 # in case we are back to top level, Issue #188
            indentStack.unshift(indent)
            orderStack.unshift(lineMeta.defaultHead)
          else
            orderStack.unshift(LineMeta.incStr(orderStack.shift()))
        else # same level ol match
          orderStack.unshift(LineMeta.incStr(orderStack.shift()))

        correctedLines[idx] = "#{indentStack[0]}#{orderStack[0]}. #{lineMeta.body}"
      else
        correctedLines[idx] = line

    correctedLines.join("\n")

  formatTable: (e, range, lines) ->
    return if lines.some (line) -> line.trim() != "" && !utils.isTableRow(line)

    { rows, options } = @_parseTable(lines)

    table = []
    # table head
    table.push(utils.createTableRow(rows[0], options).trimRight())
    # table separator
    table.push(utils.createTableSeparator(options))
    # table body
    table.push(utils.createTableRow(row, options).trimRight()) for row in rows[1..]
    # table join rows
    table.join("\n")

  _parseTable: (lines) ->
    rows = []
    options =
      numOfColumns: 1
      extraPipes: config.get("tableExtraPipes")
      columnWidth: 1
      columnWidths: []
      alignment: config.get("tableAlignment")
      alignments: []

    for line in lines
      if line.trim() == ""
        continue
      else if utils.isTableSeparator(line)
        separator = utils.parseTableSeparator(line)
        options.extraPipes = options.extraPipes || separator.extraPipes
        options.alignments = separator.alignments
        options.numOfColumns = Math.max(options.numOfColumns, separator.columns.length)
      else
        row = utils.parseTableRow(line)
        rows.push(row.columns)
        options.numOfColumns = Math.max(options.numOfColumns, row.columns.length)
        for columnWidth, i in row.columnWidths
          options.columnWidths[i] = Math.max(options.columnWidths[i] || 0, columnWidth)

    rows: rows, options: options
