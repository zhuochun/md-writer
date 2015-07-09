config = require "./config"
utils = require "./utils"

module.exports =
class StyleText
  editor: null
  style: null

  constructor: (style) ->
    @style = config.get("textStyles.#{style}")

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @editor.transact =>
      @editor.getSelections().forEach (selection) =>
        if text = selection.getText()
          @toggleStyle(selection, text)
        else
          @insertEmptyStyle(selection)

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

  isStyleOn: (text) ->
    @getStylePattern().test(text) if text

  addStyle: (text) ->
    "#{@style.before}#{text}#{@style.after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: ->
    before = @style.regexBefore || utils.regexpEscape(@style.before)
    after = @style.regexAfter || utils.regexpEscape(@style.after)
    ///
    ^([\s\S]*?)                 # random text at head
    (?:#{before}([\s\S]*?)
    #{after}([\s\S]+?))*        # the pattern can appear multiple time
    #{before}([\s\S]*?)#{after} # the pattern must appear once
    ([\s\S]*)$                  # random text at end
    ///gm
