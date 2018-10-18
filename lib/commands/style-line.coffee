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
        range = selection.getBufferRange()
        # when selection contains multiple rows, apply style to each row
        rows = selection.getBufferRowRange()
        # rows[0] = start of buffer rows, rows[1] = end of buffer rows
        for row, i in ([rows[0]..rows[1]])
          data =
            i: i + 1,
            ul: config.get("templateVariables.ulBullet#{@editor.indentationForBufferRow(row)}") || config.get("templateVariables.ulBullet")

          if line = @editor.lineTextForBufferRow(row)
            @toggleStyle(selection, line, data)
          else
            @insertEmptyStyle(selection, data)

        # select the whole range, if selection contains multiple rows
        selection.setBufferRange(range) if rows[0] != rows[1]

  insertEmptyStyle: (selection, data) ->
    selection.insertText(utils.template(@style.before, data))
    position = selection.cursor.getBufferPosition()
    selection.insertText(utils.template(@style.after, data))
    selection.cursor.setBufferPosition(position)

  toggleStyle: (selection, line, data) ->
    if @isStyleOn(line)
      @removeStyle(selection, line, data)
    else
      @addStyle(selection, line, data)

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
    selection.selectToEndOfLine()
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
