{$, View} = require "atom"
utils = require "./utils"

styles =
  h1: before: "# ", after: ""
  h2: before: "## ", after: ""
  h3: before: "### ", after: ""
  h4: before: "#### ", after: ""
  h5: before: "##### ", after: ""

module.exports =
class HeadingStyleView extends View
  editor: null
  style: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer empty"

  initialize: (style) ->
    @style = styles[style]

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()

    line = @getLine()
    if line
      @toggleStyle(line)
    else
      @insertEmptyStyle()

  getLine: ->
    @editor.moveCursorToBeginningOfLine()
    return @editor.selectToEndOfLine()[0].getText()

  toggleStyle: (text) ->
    if @isStyleOn(text)
      text = @removeStyle(text)
    else
      text = @addStyle(text)
    @editor.insertText(text)

  insertEmptyStyle: ->
    @editor.insertText(@addStyle(""))
    pos = @editor.getCursorBufferPosition()
    @editor.setCursorBufferPosition([pos.row, pos.column - @style.after.length])

  isStyleOn: (text) ->
    @getStylePattern().test(text)

  addStyle: (text) ->
    text = /^#*\s?(.+)/.exec(text)[1]
    "#{@style.before}#{text}#{@style.after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: ->
    before = utils.regexpEscape(@style.before)
    after = utils.regexpEscape(@style.after)
    /// ^#{before} (.+?) #{after}$ ///

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super
