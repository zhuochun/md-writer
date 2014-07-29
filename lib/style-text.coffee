utils = require "./utils"

# supported styles
styles =
  code: before: "`", after: "`"
  bold: before: "**", after: "**"
  italic: before: "_", after: "_"
  strikethrough: before: "~~", after: "~~"

module.exports =
class StyleText
  editor: null
  style: null

  constructor: (style) ->
    @style = styles[style]

  display: ->
    @editor = atom.workspace.getActiveEditor()
    if text = @editor.getSelectedText()
      @toggleStyle(text)
    else
      @insertEmptyStyle()

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
    @getStylePattern().test(text) if text

  addStyle: (text) ->
    "#{@style.before}#{text}#{@style.after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: ->
    before = utils.regexpEscape(@style.before)
    after = utils.regexpEscape(@style.after)
    ///
    ^(.*?) # random text at head
    (?:#{before}(.*?)#{after}(.+?))* # the pattern can appear multiple time
    #{before}(.*?)#{after} # the pattern must appear once
    (.*)$ # random text at end
    ///gm
