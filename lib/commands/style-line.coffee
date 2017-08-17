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
          data = { i: i + 1 }

          selection.cursor.setBufferPosition([row, 0])
          selection.selectToEndOfLine()

          if line = selection.getText()
            @toggleStyle(selection, line, data)
          else
            @insertEmptyStyle(selection, data)
        # select the whole range, if selection contains multiple rows
        selection.setBufferRange(range) if rows[0] != rows[1]

  toggleStyle: (selection, line, data) ->
    if @isStyleOn(line)
      text = @removeStyle(line)
    else
      text = @addStyle(line, data)

    selection.insertText(text)

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

  addStyle: (text, data) ->
    before = utils.template(@style.before, data)
    after = utils.template(@style.after, data)

    match = @getStylePattern().exec(text)
    if match
      "#{match[1]}#{before}#{match[2]}#{after}#{match[3]}"
    else
      "#{before}#{after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: ->
    before = @style.regexBefore || utils.escapeRegExp(@style.before)
    after = @style.regexAfter || utils.escapeRegExp(@style.after)

    /// ^(\s*) (?:#{before})? (.*?) (?:#{after})? (\s*)$ ///i
