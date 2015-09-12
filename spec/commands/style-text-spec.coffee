StyleText = require "../../lib/commands/style-text"

describe "StyleText", ->
  describe ".isStyleOn", ->
    it "check a style is added", ->
      cmd = new StyleText("bold")
      fixture = "**bold**"
      expect(cmd.isStyleOn(fixture)).toBe(true)

    it "check any bold style is in string", ->
      cmd = new StyleText("bold")
      fixture = "hello **bold** world"
      expect(cmd.isStyleOn(fixture)).toBe(true)

    it "check any italic is in string", ->
      cmd = new StyleText("italic")
      fixture = "_italic_ yah _text_"
      expect(cmd.isStyleOn(fixture)).toBe(true)

    it "check any strike is in string", ->
      cmd = new StyleText("strikethrough")
      fixture = "**bold** one ~~strike~~ two _italic_"
      expect(cmd.isStyleOn(fixture)).toBe(true)

    it "check a style is not added", ->
      cmd = new StyleText("bold")
      fixture = "_not bold_"
      expect(cmd.isStyleOn(fixture)).toBe(false)

  describe ".removeStyle", ->
    it "remove a style from text", ->
      cmd = new StyleText("italic")
      fixture = "_italic text_"
      expect(cmd.removeStyle(fixture)).toEqual("italic text")

    it "remove bold style from text", ->
      cmd = new StyleText("bold")
      fixture = "**bold text** in a string"
      expect(cmd.removeStyle(fixture)).toEqual("bold text in a string")

    it "remove italic styles from text", ->
      cmd = new StyleText("italic")
      fixture = "_italic_ yah _text_ loh _more_"
      expect(cmd.removeStyle(fixture)).toEqual("italic yah text loh more")

  describe ".addStyle", ->
    it "add a style to text", ->
      cmd = new StyleText("bold")
      fixture = "bold text"
      expect(cmd.addStyle(fixture)).toEqual("**bold text**")

  describe ".trigger", ->
    editor = null

    beforeEach ->
      waitsForPromise -> atom.workspace.open("empty.markdown")
      runs -> editor = atom.workspace.getActiveTextEditor()

    it "insert empty bold style", ->
      new StyleText("bold").trigger()

      expect(editor.getText()).toBe("****")
      expect(editor.getCursorBufferPosition().column).toBe(2)

    it "apply italic style to word", ->
      editor.setText("italic")
      editor.setCursorBufferPosition([0, 2])

      new StyleText("italic").trigger()

      expect(editor.getText()).toBe("_italic_")
      expect(editor.getCursorBufferPosition().column).toBe(8)

    it "remove italic style from word", ->
      editor.setText("_italic_")
      editor.setCursorBufferPosition([0, 3])

      new StyleText("italic").trigger()

      expect(editor.getText()).toBe("italic")
      expect(editor.getCursorBufferPosition().column).toBe(6)

    it "toggle code style on selection", ->
      editor.setText("some code here")
      editor.setSelectedBufferRange([[0, 5], [0, 9]])

      new StyleText("code").trigger()

      expect(editor.getText()).toBe("some `code` here")
      expect(editor.getCursorBufferPosition().column).toBe(11)
