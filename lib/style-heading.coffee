utils = require "./utils"

styles =
  h1: before: "# ", after: ""
  h2: before: "## ", after: ""
  h3: before: "### ", after: ""
  h4: before: "#### ", after: ""
  h5: before: "##### ", after: ""
  ul: before: "- ", after: ""
  ol: before: "0. ", after: ""
  blockquote: before: "> ", after: ""

module.exports =
class StyleHeading
  editor: null
  style: null

  constructor: (style) ->
    @style = styles[style]

  display: ->
    @editor = atom.workspace.getActiveEditor()
    @editor.buffer.beginTransaction()
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
    @editor.buffer.commitTransaction()

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
    match = /// ^ (\s*) #{@style.before[0]}* \s? (.*) $ ///.exec(text)
    "#{match[1]}#{@style.before}#{match[2]}#{@style.after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: ->
    before = utils.regexpEscape(@style.before)
    after = utils.regexpEscape(@style.after)
    /// ^ (\s*) #{before} (.*?) #{after}$ ///
