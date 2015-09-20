StyleLine = require "../../lib/commands/style-line"

describe "StyleLine", ->
  describe ".isStyleOn", ->
    it "check heading 1 exists", ->
      cmd = new StyleLine("h1")
      fixture = "# heading 1"
      expect(cmd.isStyleOn(fixture)).toBe(true)

    it "check heading 1 not exists", ->
      cmd = new StyleLine("h1")
      fixture = "## heading 1"
      expect(cmd.isStyleOn(fixture)).toBe(false)

    it "check ul exists", ->
      cmd = new StyleLine("ul")
      fixture = "* unordered list"
      expect(cmd.isStyleOn(fixture)).toBe(true)
      fixture = "- unordered list"
      expect(cmd.isStyleOn(fixture)).toBe(true)

    it "check ul not exists", ->
      cmd = new StyleLine("ul")
      fixture = "a normal list"
      expect(cmd.isStyleOn(fixture)).toBe(false)
      fixture = "0. ordered list"
      expect(cmd.isStyleOn(fixture)).toBe(false)

  describe ".addStyle", ->
    it "applies heading 1 styles", ->
      atom.config.set("markdown-writer.lineStyles.h1", before: "# ", after: " #")
      cmd = new StyleLine("h1")
      fixture = "## heading 1 ##"
      expect(cmd.addStyle(fixture)).toBe("# heading 1 #")

    it "applies heading 2 styles", ->
      cmd = new StyleLine("h2")
      fixture = "# heading 2"
      expect(cmd.addStyle(fixture)).toBe("## heading 2")

    it "applies blockquote styles", ->
      cmd = new StyleLine("blockquote")
      fixture = "blockquote"
      expect(cmd.addStyle(fixture)).toBe("> blockquote")

  describe ".removeStyle", ->
    it "applies heading 1 styles", ->
      atom.config.set("markdown-writer.lineStyles.h1", before: "# ", after: " #")
      cmd = new StyleLine("h1")
      fixture = "# heading 1 #"
      expect(cmd.removeStyle(fixture)).toBe("heading 1")

    it "remove heading 3 styles", ->
      cmd = new StyleLine("h3")
      fixture = "### heading 3"
      expect(cmd.removeStyle(fixture)).toBe("heading 3")

    it "remove ol styles", ->
      cmd = new StyleLine("ol")
      fixture = "123. ordered list"
      expect(cmd.removeStyle(fixture)).toBe("ordered list")

  describe ".trigger", ->
    editor = null

    beforeEach ->
      waitsForPromise -> atom.workspace.open("empty.markdown")
      runs -> editor = atom.workspace.getActiveTextEditor()

    it "insert empty blockquote style", ->
      new StyleLine("blockquote").trigger()
      expect(editor.getText()).toBe("> ")
      expect(editor.getCursorBufferPosition().column).toBe(2)

    it "apply heading 2", ->
      editor.setText("# heading")

      new StyleLine("h2").trigger()
      expect(editor.getText()).toBe("## heading")
      expect(editor.getCursorBufferPosition().column).toBe(10)

    it "remove heading 3", ->
      editor.setText("### heading")

      new StyleLine("h3").trigger()
      expect(editor.getText()).toBe("heading")
      expect(editor.getCursorBufferPosition().column).toBe(7)

    it "apply ordered/unordered list", ->
      editor.setText("- list")

      new StyleLine("ol").trigger()
      expect(editor.getText()).toBe("1. list")
      expect(editor.getCursorBufferPosition().column).toBe(7)

      new StyleLine("ul").trigger()
      expect(editor.getText()).toBe("- list")
      expect(editor.getCursorBufferPosition().column).toBe(6)

    it "apply task/taskdone list", ->
      editor.setText("task")

      new StyleLine("task").trigger()
      expect(editor.getText()).toBe("- [ ] task")

      new StyleLine("taskdone").trigger()
      expect(editor.getText()).toBe("- [X] task")

      new StyleLine("task").trigger()
      expect(editor.getText()).toBe("- [ ] task")

      new StyleLine("task").trigger()
      expect(editor.getText()).toBe("task")
