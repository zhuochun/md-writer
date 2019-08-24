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
      editor.setCursorBufferPosition([1, 20])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. [ ] Epic Tasks"
        "   1. [X] Sub-task A"
        "   2. [ ] " # last item with trailing whitespace
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
      editor.setCursorBufferPosition([1, 20])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. [ ] Epic Tasks"
        "   y. [X] Sub-task A"
        "   z. [ ] " # last item with trailing whitespace
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
        "   - child"
        "   - " # last item with trailing whitespace
      ].join("\n")
      editor.setCursorBufferPosition([2, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. [ ] parent"
        "   - child"
        "2. [ ] " # last item with trailing whitespace
      ].join("\n")

    it "not continue after empty ordered paragraph", ->
      editor.setText [
        "1. parent"
        "   - child has a paragraph"
        ""
        "     paragraph one"
        ""
        "     paragraph two"
        ""
        "   - " # last item with trailing whitespace
      ].join("\n")
      editor.setCursorBufferPosition([7, 5])

      editLine.trigger(event)
      expect(editor.getText()).toBe [
        "1. parent"
        "   - child has a paragraph"
        ""
        "     paragraph one"
        ""
        "     paragraph two"
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

    describe "unordered list", ->
      beforeEach ->
        editor.setText [
            "- list"
            "- list line 2"
            "  - list line 3"
          ].join("\n")

      it "pass 1st line", ->
        editor.setCursorBufferPosition([0, 5])
        editLine.trigger(event)
        expect(event.abortKeyBinding).toHaveBeenCalled()

      it "indent 2nd line", ->
        editor.setCursorBufferPosition([1, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "- list"
            "  - list line 2"
            "  - list line 3"
          ].join("\n")
        expect(editor.getCursorBufferPosition().toString()).toBe("(1, 7)")

      it "indent 2nd line with ulBullet config", ->
        atom.config.set("markdown-writer.templateVariables.ulBullet1", "*")
        atom.config.set("markdown-writer.templateVariables.ulBullet2", "+")

        editor.setCursorBufferPosition([1, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "- list"
            "  * list line 2"
            "  - list line 3"
          ].join("\n")

        editor.setCursorBufferPosition([2, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "- list"
            "  * list line 2"
            "    + list line 3"
          ].join("\n")

    describe "ordered list", ->
      beforeEach ->
        editor.setText [
            "1. list"
            "2. list line 2"
            "3. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
            ""
            "This behaviour is not observed when the list item does not extend to the next line."
          ].join("\n")

      it "pass 1st line", ->
        editor.setCursorBufferPosition([0, 5])
        editLine.trigger(event)
        expect(event.abortKeyBinding).toHaveBeenCalled()

      it "indent 2nd line", ->
        editor.setCursorBufferPosition([1, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "   1. list line 2"
            "3. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
            ""
            "This behaviour is not observed when the list item does not extend to the next line."
          ].join("\n")
        expect(editor.getCursorBufferPosition().toString()).toBe("(1, 8)")

      it "indent 3rd long text line", ->
        editor.setCursorBufferPosition([2, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "2. list line 2"
            "   1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
            ""
            "This behaviour is not observed when the list item does not extend to the next line."
          ].join("\n")
        expect(editor.getCursorBufferPosition().toString()).toBe("(2, 8)")

    describe "mixed ordered list", ->
      beforeEach ->
        editor.setText [
            "1. list"
            "- list line 2"
            "- list line 3"
          ].join("\n")

      it "indent 2nd line", ->
        editor.setCursorBufferPosition([1, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "   - list line 2"
            "- list line 3"
          ].join("\n")
        expect(editor.getCursorBufferPosition().toString()).toBe("(1, 8)")

      it "indent 2nd/3rd line with ulBullet config", ->
        atom.config.set("markdown-writer.templateVariables.ulBullet1", "*")
        atom.config.set("markdown-writer.templateVariables.ulBullet2", "+")

        editor.setCursorBufferPosition([1, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "   * list line 2"
            "- list line 3"
          ].join("\n")

        editor.setCursorBufferPosition([2, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "   * list line 2"
            "   * list line 3"
          ].join("\n")

        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "   * list line 2"
            "     + list line 3"
          ].join("\n")

  describe "undentListLine", ->
    beforeEach -> editLine = new EditLine("undent-list-line")

    describe "unordered list", ->
      beforeEach ->
        editor.setText [
            "- list"
            "  * list line 2"
            "    + list line 3"
          ].join("\n")

      it "pass 1st line", ->
        editor.setCursorBufferPosition([0, 5])
        editLine.trigger(event)
        expect(event.abortKeyBinding).toHaveBeenCalled()

      it "undent 2nd line", ->
        editor.setCursorBufferPosition([1, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "- list"
            "- list line 2"
            "    + list line 3"
          ].join("\n")
        expect(editor.getCursorBufferPosition().toString()).toBe("(1, 3)")

        editor.setCursorBufferPosition([2, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "- list"
            "- list line 2"
            "  - list line 3"
          ].join("\n")

      it "undent 2nd line with ulBullet config", ->
        editor.setCursorBufferPosition([2, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "- list"
            "  * list line 2"
            "  * list line 3"
          ].join("\n")

    describe "mixed ordered list", ->
      beforeEach ->
        editor.setText [
            "1. list"
            "   - list line 2"
            "     1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
            ""
            "This behaviour is not observed when the list item does not extend to the next line."
          ].join("\n")

      it "pass 1st line", ->
        editor.setCursorBufferPosition([0, 5])
        editLine.trigger(event)
        expect(event.abortKeyBinding).toHaveBeenCalled()

      it "undent 2nd line", ->
        editor.setCursorBufferPosition([1, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "1. list line 2"
            "     1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
            ""
            "This behaviour is not observed when the list item does not extend to the next line."
          ].join("\n")
        expect(editor.getCursorBufferPosition().toString()).toBe("(1, 3)")

        editor.setCursorBufferPosition([2, 5])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "1. list line 2"
            "     1. Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
            ""
            "This behaviour is not observed when the list item does not extend to the next line."
          ].join("\n")
        expect(event.abortKeyBinding).toHaveBeenCalled()

      it "undent 3rd long text line", ->
        editor.setCursorBufferPosition([2, 1])
        editLine.trigger(event)
        expect(editor.getText()).toBe [
            "1. list"
            "   - list line 2"
            "   - Consider a (ordered or unordered) markdown list. On pressing tab to indent the item, if the item spans over more than one line, then the text of the item alters. See the below gif in https://github.com/zhuochun/md-writer/issues/222"
            ""
            "This behaviour is not observed when the list item does not extend to the next line."
          ].join("\n")
        expect(editor.getCursorBufferPosition().toString()).toBe("(2, 0)")
