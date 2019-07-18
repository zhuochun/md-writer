config = require "../config"
utils = require "../utils"

module.exports =
class StyleLine
  # @style config could contains:
  #
  # - before (required)
  # - after (required)
  # - regexBefore (optional) overwrites before when to match/replace string
  # - regexAfter (optional) overwrites after when to match/replace string
  # - regexMatchBefore (optional) to detect a string match the style pattern
  # - regexMatchAfter (optional) to detect a string match the style pattern
  #
  constructor: (style) ->
    @style = config.get("lineStyles.#{style}")
    # make sure before/after exist
    @style.before ?= ""
    @style.after ?= ""
    # use regexBefore, regexAfter if not specified
    @style.regexMatchBefore ?= @style.regexBefore || @style.before
    @style.regexMatchAfter ?= @style.regexAfter || @style.after
    # set regexBefore for headings that only need to check the 1st char
    @style.regexBefore ?= "#{@style.before[0]}+\\s" if @style.before
    @style.regexAfter ?= "\\s#{@style.after[@style.after.length - 1]}*" if @style.after

  trigger: (e) ->
    @editor = atom.workspace.getActiveTextEditor()
    @editor.transact =>
      @editor.getSelections().forEach (selection) =>
        # get rows covered by the range, e.g. single row=[83, 83], multiple rows=[81, 83]
        rows = selection.getBufferRowRange()
        # check the range has multiple rows, apply different rules
        if rows[0] == rows[1]
          @applySingleRow(selection, rows)
        else
          @applyMultiRows(selection, rows)

  applySingleRow: (selection, rows) ->
    row = rows[0]
    indent = @editor.indentationForBufferRow(row)
    data =
      i: 1,
      ul: config.get("templateVariables.ulBullet#{indent}") || config.get("templateVariables.ulBullet")

    if line = @editor.lineTextForBufferRow(row)
      if @isStyleOn(line)
        @removeStyle(selection, line, data)
      else
        @addStyle(selection, line, data)
    else
      @insertEmptyStyle(selection, data)

  applyMultiRows: (selection, rows) ->
    range = selection.getBufferRange() # cache current selection range

    # find the action of first row as the indication
    line = @editor.lineTextForBufferRow(rows[0])
    isRemoveStyle = line && @isStyleOn(line) # else add style

    lineIdx = 0
    rowsToRemove = []

    # rows[0] = start of buffer rows, rows[1] = end of buffer rows
    for row in ([rows[0]..rows[1]])
      line = @editor.lineTextForBufferRow(row)
      # record lines to be removed
      if !line && @style.removeEmptyLine
        rowsToRemove.push(row)
        continue

      lineIdx += 1

      indent = @editor.indentationForBufferRow(row)
      data =
        i: lineIdx,
        ul: config.get("templateVariables.ulBullet#{indent}") || config.get("templateVariables.ulBullet")

      # we need to move cursor to each row start to perform action on line
      selection.cursor.setBufferPosition([row, 0])

      if line && isRemoveStyle
        @removeStyle(selection, line, data)
      else if line
        @addStyle(selection, line, data)
      else if !isRemoveStyle
        @insertEmptyStyle(selection, data)

    # remove deleted line
    for row, i in rowsToRemove
      @editor.getBuffer().deleteRow(row - i)

    # reselect from start of char in range
    range.start.column = 0
    # to end of last char
    range.end.row -= rowsToRemove.length
    range.end.column = @editor.lineTextForBufferRow(range.end.row).length

    selection.setBufferRange(range) # reselect the spreviously selected range

  insertEmptyStyle: (selection, data) ->
    selection.insertText(utils.template(@style.before, data))
    position = selection.cursor.getBufferPosition()
    selection.insertText(utils.template(@style.after, data))
    selection.cursor.setBufferPosition(position)

  # use regexMatchBefore/regexMatchAfter to match the string
  isStyleOn: (text) ->
    /// ^(\s*)                   # start with any spaces
    #{@style.regexMatchBefore}   # style start
      (.*?)                      # any text
    #{@style.regexMatchAfter}    # style end
    (\s*)$ ///i.test(text)

  addStyle: (selection, text, data) ->
    # ["- [ ] body", "", "- [ ] ", "body", undefined, ""]
    match = @getStylePattern().exec(text)
    return unless match # ignore cases that not match, which shouldn't be
    # ["- [ ] body", "", "- [ ] ", "-", "body", undefined, ""] (with capture=true)
    if @style.captureBefore
      data["captureBefore"] = match.splice(3, 1)[0] || data[@style.captureBefore]

    # construct new before/after text
    newBefore = utils.template(@style.before, data)
    newAfter = utils.template(@style.after, data)
    @applyStyle(selection, match, newBefore, newAfter)

  removeStyle: (selection, text, data) ->
    # ["- [ ] body", "", "- [ ] ", "body", undefined, ""]
    match = @getStylePattern().exec(text)
    return unless match # ignore cases that not match, which shouldn't be
    # ["- [ ] body", "", "- [ ] ", "-", "body", undefined, ""] (with capture=true)
    if @style.captureBefore
      data["captureBefore"] = match.splice(3, 1)[0] || data[@style.captureBefore]

    # construct new before/after text
    newBefore = utils.template(@style.emptyBefore || "", data)
    newAfter = utils.template(@style.emptyAfter || "", data)
    @applyStyle(selection, match, newBefore, newAfter)

  applyStyle: (selection, match, newBefore, newAfter) ->
    position = selection.cursor.getBufferPosition()

    # replace text in line
    selection.cursor.setBufferPosition([position.row, 0])
    selection.selectToEndOfBufferLine()
    selection.insertText("#{match[1]}#{newBefore}#{match[3]}#{newAfter}#{match[5]}")

    # recover original position in the new text
    m1 = match[1].length
    m2 = (match[2] || "").length
    m3 = match[3].length
    m4 = (match[4] || "").length
    # find new position
    if position.column < m1
      # no change
    else if position.column < m1 + m2
      position.column = m1 + newBefore.length # move to end of newBefore
    else if position.column < m1 + m2 + m3
      position.column += newBefore.length - m2
    else if position.column < m1 + m2 + m3 + m4
      position.column += m1 + m2 + m3 + newAfter.length # move to end of newAfter
    else # at the end of line
      position = selection.cursor.getBufferPosition()
    # set cursor position
    selection.cursor.setBufferPosition(position)

  getStylePattern: ->
    before = @style.regexBefore || utils.escapeRegExp(@style.before)
    after = @style.regexAfter || utils.escapeRegExp(@style.after)

    /// ^(\s*) (#{before})? (.*?) (#{after})? (\s*)$ ///i
