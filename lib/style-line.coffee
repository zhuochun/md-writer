config = require "./config"
utils = require "./utils"

module.exports =
class StyleLine
  editor: null
  style: null

  constructor: (style) ->
    @style = config.get("lineStyles.#{style}")

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @editor.transact =>
      @editor.getSelections().forEach (selection) =>
        range = selection.getBufferRange()
        rows = selection.getBufferRowRange()
        for row in [rows[0]..rows[1]]
          selection.cursor.setBufferPosition([row,0])
          if line = @getLine(selection)
            @toggleStyle(selection, line)
          else
            @insertEmptyStyle(selection)
        selection.setBufferRange(range) if rows[0] != rows[1]

  getLine: (selection) ->
    selection.selectToEndOfLine()
    return selection.getText()

  toggleStyle: (selection, text) ->
    if @isStyleOn(text)
      text = @removeStyle(text)
    else
      text = @addStyle(text)
    selection.insertText(text)

  insertEmptyStyle: (selection) ->
    selection.insertText(@addStyle(""))

  isStyleOn: (text) ->
    @getStylePattern().test(text)

  addStyle: (text) ->
    prefix = @style.prefix || @style.before[0]
    match = @getStylePattern("(?:#{prefix})*\\s?").exec(text)
    return "#{match[1]}#{@style.before}#{match[2]}#{@style.after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: (before, after) ->
    before ?= utils.regexpEscape(@style.before)
    after  ?= utils.regexpEscape(@style.after)
    return /// ^ (\s*) #{before} (.*?) #{after}$ ///
