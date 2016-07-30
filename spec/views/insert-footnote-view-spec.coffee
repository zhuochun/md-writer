InsertFootnoteView = require "../../lib/views/insert-footnote-view"

describe "InsertFootnoteView", ->
  [editor, insertFootnoteView] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")
    runs ->
      insertFootnoteView = new InsertFootnoteView({})
      editor = atom.workspace.getActiveTextEditor()

  describe ".display", ->
    it "display without set footnote", ->
      insertFootnoteView.display()
      expect(insertFootnoteView.footnote).toBeUndefined()
      expect(insertFootnoteView.labelEditor.getText().length).toEqual(8)

    it "display with footnote set", ->
      editor.setText "[^1]"
      editor.setCursorBufferPosition([0, 0])
      editor.selectToEndOfLine()

      insertFootnoteView.display()
      expect(insertFootnoteView.footnote).toEqual(label: "1", content: "", isDefinition: false)
      expect(insertFootnoteView.labelEditor.getText()).toEqual("1")

  describe ".insertFootnote", ->
    it "insert footnote with content", ->
      insertFootnoteView.display()
      insertFootnoteView.insertFootnote(label: "footnote", content: "content")

      expect(editor.getText()).toEqual """
[^footnote]

[^footnote]: content
      """

  describe ".updateFootnote", ->
    fixture = """
[^footnote]

[^footnote]:
content
    """

    expected = """
[^note]

[^note]:
content
    """

    beforeEach ->
      editor.setText(fixture)

    it "update footnote definition to new label", ->
      editor.setCursorBufferPosition([0, 0])
      editor.selectToEndOfLine()

      insertFootnoteView.display()
      insertFootnoteView.updateFootnote(label: "note", content: "")

      expect(editor.getText()).toEqual(expected)

    it "update footnote reference to new label", ->
      editor.setCursorBufferPosition([2, 0])
      editor.selectToBufferPosition([2, 13])

      insertFootnoteView.display()
      insertFootnoteView.updateFootnote(label: "note", content: "")

      expect(editor.getText()).toEqual(expected)
