config = require "../config"
utils = require "../utils"

# Map markdown-writer text style keys to official gfm style scope selectors
scopeSelectors =
  code: ".raw"
  bold: ".bold"
  italic: ".italic"
  strikethrough: ".strike"

module.exports =
class StyleText
  # @style config could contains:
  #
  # - before (required)
  # - after (required)
  # - regexBefore (optional) overwrites before when to match/replace string
  # - regexAfter (optional) overwrites after when to match/replace string
  #
  constructor: (style) ->
    @styleName = style
    @style = config.get("textStyles.#{style}")
    # make sure before/after exist
    @style.before ?= ""
    @style.after ?= ""

  trigger: (e) ->
    @editor = atom.workspace.getActiveTextEditor()
    @editor.transact =>
      @editor.getSelections().forEach (selection) =>
        retainSelection = !selection.isEmpty()
        @normalizeSelection(selection)

        if text = selection.getText()
          @toggleStyle(selection, text, select: retainSelection)
        else
          @insertEmptyStyle(selection)

  # try to act smart to correct the selection if needed
  normalizeSelection: (selection) ->
    scopeSelector = scopeSelectors[@styleName]
    return unless scopeSelector

    range = utils.getTextBufferRange(@editor, scopeSelector, selection)
    selection.setBufferRange(range)

  toggleStyle: (selection, text, opts) ->
    if @isStyleOn(text)
      text = @removeStyle(text)
    else
      text = @addStyle(text)

    selection.insertText(text, opts)

  insertEmptyStyle: (selection) ->
    selection.insertText(@style.before)
    position = selection.cursor.getBufferPosition()
    selection.insertText(@style.after)
    selection.cursor.setBufferPosition(position)

  isStyleOn: (text) ->
    @getStylePattern().test(text) if text

  addStyle: (text) ->
    "#{@style.before}#{text}#{@style.after}"

  removeStyle: (text) ->
    while matches = @getStylePattern().exec(text)
      text = matches[1..].join("")
    return text

  getStylePattern: ->
    before = @style.regexBefore || utils.escapeRegExp(@style.before)
    after = @style.regexAfter || utils.escapeRegExp(@style.after)

    ///
    ^([\s\S]*?)                    # random text at head
    #{before}([\s\S]*?)#{after}    # the style pattern appear once
    ([\s\S]*?)$                    # random text at end
    ///gm
