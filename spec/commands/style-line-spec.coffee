StyleLine = require "../../lib/commands/style-line"

describe "StyleLine", ->
  editor = null

  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")
    runs -> editor = atom.workspace.getActiveTextEditor()

  describe "blockquote", ->
    it "insert empty blockquote", ->
      new StyleLine("blockquote").trigger()
      expect(editor.getText()).toBe("> ")
      expect(editor.getCursorBufferPosition().column).toBe(2)

    it "remove blockquote", ->
      editor.setText("> blockquote")
      editor.setCursorBufferPosition([0, 4])

      new StyleLine("blockquote").trigger()
      expect(editor.getText()).toBe("blockquote")
      expect(editor.getCursorBufferPosition().column).toBe(2)

  describe "headings", ->
    it "apply heading 2", ->
      editor.setText("# heading")
      editor.setCursorBufferPosition([0, 3])

      new StyleLine("h2").trigger()
      expect(editor.getText()).toBe("## heading")
      expect(editor.getCursorBufferPosition().column).toBe(4)

    it "remove heading 3", ->
      editor.setText("### heading")
      editor.setCursorBufferPosition([0, 7])

      new StyleLine("h3").trigger()
      expect(editor.getText()).toBe("heading")
      expect(editor.getCursorBufferPosition().column).toBe(3)

    it "apply/remove heading 5", ->
      atom.config.set("markdown-writer.lineStyles.h5", before: "##### ", after: " #####")

      editor.setText("## heading")
      editor.setCursorBufferPosition([0, 2]) # inside ##

      new StyleLine("h5").trigger()
      expect(editor.getText()).toBe("##### heading #####")
      expect(editor.getCursorBufferPosition().column).toBe(6) # move to end of #

      editor.setCursorBufferPosition([0, 16]) # close to the end of line

      new StyleLine("h5").trigger()
      expect(editor.getText()).toBe("heading")
      expect(editor.getCursorBufferPosition().column).toBe(7)

  describe "lists", ->
    it "apply ordered/unordered list", ->
      editor.setText("- list")

      new StyleLine("ol").trigger()
      expect(editor.getText()).toBe("1. list")
      expect(editor.getCursorBufferPosition().column).toBe(7)

      new StyleLine("ul").trigger()
      expect(editor.getText()).toBe("- list")
      expect(editor.getCursorBufferPosition().column).toBe(6)

    it "apply ordered/unordered list on multiple rows", ->
      editor.setText """
      - list 1
      list 2
      - list 3
      """
      editor.setSelectedBufferRange([[0,0], [3, 0]])

      new StyleLine("ol").trigger()
      expect(editor.getText()).toBe """
      1. list 1
      2. list 2
      3. list 3
      """

      new StyleLine("ul").trigger()
      expect(editor.getText()).toBe """
      - list 1
      - list 2
      - list 3
      """

    it "apply task list", ->
      editor.setText("task")

      new StyleLine("task").trigger()
      expect(editor.getText()).toBe("- [ ] task")

      new StyleLine("task").trigger()
      expect(editor.getText()).toBe("task")

    it "apply task ol list", ->
      editor.setText("1. task")

      new StyleLine("task").trigger()
      expect(editor.getText()).toBe("1. [ ] task")

      new StyleLine("task").trigger()
      expect(editor.getText()).toBe("task")

    it "apply taskdone ol list", ->
      editor.setText("1. [ ] task")

      new StyleLine("taskdone").trigger()
      expect(editor.getText()).toBe("1. [x] task")

      new StyleLine("taskdone").trigger()
      expect(editor.getText()).toBe("1. [ ] task")
