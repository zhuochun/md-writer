EditLine = require "../../lib/commands/edit-line"

describe "EditLine", ->
  [editor, editLine, event] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")
    runs ->
      editor = atom.workspace.getActiveTextEditor()

      event = { abortKeyBinding: -> {} }
      spyOn(event, "abortKeyBinding")

  describe "insertNewLine", ->
    beforeEach -> editLine = new EditLine("insert-new-line")

    it "does not affect normal new line", ->
      editor.setText "this is normal line"
      editor.setCursorBufferPosition([0, 4])

      editLine.trigger(event)
      expect(event.abortKeyBinding).toHaveBeenCalled()

    it "continue if config inlineNewLineContinuation enabled", ->
      atom.config.set("markdown-writer.inlineNewLineContinuation", true)

      editor.setText "- inline line"
      editor.setCursorBufferPosition([0, 8])

      editLine.trigger(event)
      expect(editor.getText()).toBe """
      - inline
      -  line
      """

    it "continue after unordered list line", ->
      editor.setText "- line"
      editor.setCursorBufferPosition([0, 6])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "- line"
        "- " # last item with trailing whitespace
      ].join("\n")

    it "continue after nested unordered list line", ->
      editor.setText """
      - line 0
        * line 1
          + line 2
      """
      editor.setCursorBufferPosition([2, 12])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "- line 0"
        "  * line 1"
        "    + line 2"
        "    + " # last item with trailing whitespace
      ].join("\n")

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "- line 0"
        "  * line 1"
        "    + line 2"
        "  * " # last item with trailing whitespace
      ].join("\n")

    it "continue after ordered task list line", ->
      editor.setText """
      1. [ ] Epic Tasks
        1. [X] Sub-task A
      """
      editor.setCursorBufferPosition([1, 19])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. [ ] Epic Tasks"
        "  1. [X] Sub-task A"
        "  2. [ ] " # last item with trailing whitespace
      ].join("\n")

    it "continue after ordered task list line (without number continuation)", ->
      atom.config.set("markdown-writer.orderedNewLineNumberContinuation", false)

      editor.setText """
      1. Epic Order One
      """
      editor.setCursorBufferPosition([0, 17])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. Epic Order One"
        "1. " # last item with trailing whitespace
      ].join("\n")

    it "not continue after unindented alpha ordered list line", ->
      editor.setText """a. Epic Tasks"""
      editor.setCursorBufferPosition([0, 13])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "a. Epic Tasks"
      ].join("\n")

    it "continue after alpha ordered task list line", ->
      editor.setText """
      1. [ ] Epic Tasks
        y. [X] Sub-task A
      """
      editor.setCursorBufferPosition([1, 19])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. [ ] Epic Tasks"
        "  y. [X] Sub-task A"
        "  z. [ ] " # last item with trailing whitespace
      ].join("\n")

    it "continue after blockquote line", ->
      editor.setText """
      > Your time is limited, so don’t waste it living someone else’s life.
      """
      editor.setCursorBufferPosition([0, 69])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "> Your time is limited, so don’t waste it living someone else’s life."
        "> " # last item with trailing whitespace
      ].join("\n")

    it "not continue after empty unordered task list line", ->
      editor.setText """
      - [ ]
      """
      editor.setCursorBufferPosition([0, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe ["", ""].join("\n")

    it "not continue after empty ordered list line", ->
      editor.setText [
        "1. [ ] parent"
        "  - child"
        "  - " # last item with trailing whitespace
      ].join("\n")
      editor.setCursorBufferPosition([2, 4])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. [ ] parent"
        "  - child"
        "2. [ ] " # last item with trailing whitespace
      ].join("\n")

    it "not continue after empty ordered paragraph", ->
      editor.setText [
        "1. parent"
        "  - child has a paragraph"
        ""
        "    paragraph one"
        ""
        "    paragraph two"
        ""
        "  - " # last item with trailing whitespace
      ].join("\n")
      editor.setCursorBufferPosition([7, 4])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. parent"
        "  - child has a paragraph"
        ""
        "    paragraph one"
        ""
        "    paragraph two"
        ""
        "2. " # last item with trailing whitespace
      ].join("\n")

  describe "insertNewLine (Table)", ->
    beforeEach ->
      editLine = new EditLine("insert-new-line")
      editor.setText [
        "a | b | c"
        "a | b | c"
        ""
        "random line | with bar"
        ""
        "a | b | c"
        "--|---|--"
        "a | b | c"
        "a | b | c"
        "  |   |  "
      ].join("\n")

    it "continue after table separator", ->
      editor.setCursorBufferPosition([6, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "a | b | c"
        "a | b | c"
        ""
        "random line | with bar"
        ""
        "a | b | c"
        "--|---|--"
        "  |   |  "
        "a | b | c"
        "a | b | c"
        "  |   |  "
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(7, 0)")

    it "continue after table rows", ->
      editor.setCursorBufferPosition([1, 9])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "a | b | c"
        "a | b | c"
        "  |   |  "
        ""
        "random line | with bar"
        ""
        "a | b | c"
        "--|---|--"
        "a | b | c"
        "a | b | c"
        "  |   |  "
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(2, 0)")

    it "continue in a table row", ->
      editor.setCursorBufferPosition([7, 3])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "a | b | c"
        "a | b | c"
        ""
        "random line | with bar"
        ""
        "a | b | c"
        "--|---|--"
        "a | b | c"
        "  |   |  "
        "a | b | c"
        "  |   |  "
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(8, 0)")

    it "not continue after empty table row", ->
      editor.setCursorBufferPosition([9, 8])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "a | b | c"
        "a | b | c"
        ""
        "random line | with bar"
        ""
        "a | b | c"
        "--|---|--"
        "a | b | c"
        "a | b | c"
        ""
        ""
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(10, 0)")

    it "has not effect at table head", ->
      editor.setCursorBufferPosition([5, 9])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "a | b | c"
        "a | b | c"
        ""
        "random line | with bar"
        ""
        "a | b | c"
        "--|---|--"
        "a | b | c"
        "a | b | c"
        "  |   |  "
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(5, 9)")

    it "has not effect at random line", ->
      editor.setCursorBufferPosition([3, 9])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "a | b | c"
        "a | b | c"
        ""
        "random line | with bar"
        ""
        "a | b | c"
        "--|---|--"
        "a | b | c"
        "a | b | c"
        "  |   |  "
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(3, 9)")

  describe "indentListLine", ->
    beforeEach -> editLine = new EditLine("indent-list-line")

    it "indent line if it is an unordered list", ->
      editor.setText "- list"
      editor.setCursorBufferPosition([0, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe("  - list")

    it "indent line if it is an ordered list", ->
      editor.setText "3. list"
      editor.setCursorBufferPosition([0, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe("  1. list")
      expect(editor.getCursorBufferPosition().toString()).toBe("(0, 7)")

    it "indent long line if it is an ordered list", ->
      editor.setText [
          "3. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
          ""
          "This behaviour is not observed when the list item does not extend to the next line."
        ].join("\n")
      editor.setCursorBufferPosition([0, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "  1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
        ""
        "This behaviour is not observed when the list item does not extend to the next line."
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(0, 7)")

      # indent one more time
      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "    1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
        ""
        "This behaviour is not observed when the list item does not extend to the next line."
      ].join("\n")
      expect(editor.getCursorBufferPosition().toString()).toBe("(0, 9)")

    it "abort event if it is normal text", ->
      editor.setText "texttext"
      editor.setCursorBufferPosition([0, 4])

      editLine.trigger(event)
      expect(event.abortKeyBinding).toHaveBeenCalled()

  describe "undentListLine", ->
    beforeEach -> editLine = new EditLine("undent-list-line")

    it "undent line if it is an unordered list", ->
      editor.setText "  * list"
      editor.setCursorBufferPosition([0, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe("- list")
      expect(editor.getCursorBufferPosition().toString()).toBe("(0, 3)")

    it "undent line if it is an ordered list", ->
      editor.setText "    3. list"
      editor.setCursorBufferPosition([0, 9])

      editLine.trigger(event)
      expect(editor.getText()).toBe("  1. list")

    it "undent long line if it is an ordered list", ->
      editor.setText [
          "    3. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
          ""
          "This behaviour is not observed when the list item does not extend to the next line."
        ].join("\n")
      editor.setCursorBufferPosition([0, 9])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "  1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
        ""
        "This behaviour is not observed when the list item does not extend to the next line."
      ].join("\n")

      # indent one more time
      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
        ""
        "This behaviour is not observed when the list item does not extend to the next line."
      ].join("\n")

    it "abort event if it is normal text", ->
      editor.setText "texttext"
      editor.setCursorBufferPosition([0, 4])

      editLine.trigger(event)
      expect(event.abortKeyBinding).toHaveBeenCalled()

    it "abort event if it has nothing to unindent", ->
      editor.setText "- list"
      editor.setCursorBufferPosition([0, 2])

      editLine.trigger(event)
      expect(event.abortKeyBinding).toHaveBeenCalled()
