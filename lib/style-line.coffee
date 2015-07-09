config = require "./config"
utils = require "./utils"

module.exports =
class StyleLine
  editor: null
  style: null

  # @style config could contains:
  #
  # - before (required)
  # - after (required)
  # - regexBefore (optional) overwrites before when to match/replace string
  # - regexAfter (optional) overwrites after when to match/replace string
  # - regexMatchBefore (optional) used to detect a string match the style pattern
  # - regexMatchAfter (optional) used to detect a string match the style pattern
  #
  constructor: (style) ->
    @style = config.get("lineStyles.#{style}")
    # make sure before/after exist
    @style.before ?= ""
    @style.after ?= ""
    # use regexBefore, regexAfter if not specified
    @style.regexMatchBefore ?= @style.regexBefore || @style.before
    @style.regexMatchAfter ?= @style.regexAfter || @style.after
    # construct regexBefore for headings etc that only need to take the first char
    @style.regexBefore ?= "(?:#{@style.before[0]})+\\s" if @style.before

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @editor.transact =>
      @editor.getSelections().forEach (selection) =>
        range = selection.getBufferRange()
        # when selection contains multiple rows, apply style to each row
        rows  = selection.getBufferRowRange()
        for row in [rows[0]..rows[1]]
          selection.cursor.setBufferPosition([row,0])
          selection.selectToEndOfLine()

          if line = selection.getText()
            @toggleStyle(selection, line)
          else
            @insertEmptyStyle(selection)
        # select the whole range, if selection contains multiple rows
        selection.setBufferRange(range) if rows[0] != rows[1]

  toggleStyle: (selection, text) ->
    if @isStyleOn(text)
      text = @removeStyle(text)
    else
      text = @addStyle(text)
    selection.insertText(text)

  insertEmptyStyle: (selection) ->
    selection.insertText(@style.before)
    position = selection.cursor.getBufferPosition()
    selection.insertText(@style.after)
    selection.cursor.setBufferPosition(position)

  # use regexMatchBefore/regexMatchAfter to match the string
  isStyleOn: (text) ->
    /// ^ (\s*) #{@style.regexMatchBefore} (.*?) #{@style.regexMatchAfter} $ ///i.test(text)

  addStyle: (text) ->
    match = @getStylePattern().exec(text)
    if match
      "#{match[1]}#{@style.before}#{match[2]}#{@style.after}"
    else
      "#{@style.before}#{@style.after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: ->
    before = @style.regexBefore || utils.regexpEscape(@style.before)
    after = @style.regexAfter || utils.regexpEscape(@style.after)
    return /// ^ (\s*) (?:#{before})? (.*?) (?:#{after})? $ ///i
