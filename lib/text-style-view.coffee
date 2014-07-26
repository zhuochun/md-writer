{$, View} = require "atom"
utils = require "./utils"

# supported styles
styles =
  bold: before: "**", after: "**"
  italic: before: "_", after: "_"
  strikethrough: before: "~~", after: "~~"

module.exports =
class TextStyleView extends View
  editor: null
  style: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "empty"

  initialize: (style) ->
    @style = styles[style]

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()
    @toggleStyle()

  toggleStyle: ->
    text = @editor.getSelectedText()
    if @isStyleOn(text)
      text = @removeStyle(text)
    else
      text = @addStyle(text)
    @editor.insertText(text)

  isStyleOn: (text) ->
    return false unless text
    @getStylePattern().test(text)

  addStyle: (text) ->
    "#{@style.before}#{text}#{@style.after}"

  removeStyle: (text) ->
    text.match(@getStylePattern())[1]

  getStylePattern: ->
    ///
    ^
    #{utils.regexpEscape(@style.before)}
    (.*)
    #{utils.regexpEscape(@style.after)}
    $
    ///

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super
