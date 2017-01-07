FormatText = require "../../lib/commands/format-text"

describe "FormatText", ->
  [editor, formatText] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")
    waitsForPromise -> atom.packages.activatePackage("language-gfm")
    runs -> editor = atom.workspace.getActiveTextEditor()

  describe "correctOrderListNumbers", ->
    beforeEach -> formatText = new FormatText("correct-order-list-numbers")

    it "does nothing if it is not an order list", ->
      editor.setText """
      text is a long paragraph
      text is a long paragraph
      """
      editor.setCursorBufferPosition([0, 3])

      formatText.trigger()
      expect(editor.getText()).toBe """
      text is a long paragraph
      text is a long paragraph
      """

    it "correct order list numbers", ->
      editor.setText """
      text before

      3. aaa
      9. bbb
        a. 11aa
        e. 22bb
          DD. a1
      0. ccc
        9. aaa
          - aaa
        1. bbb
        1. ccc
          0. aaa
            7. aaa
              - aaa
              - bbb
          9. bbb
        4. ddd
      7. ddd
      7. eee

      text after
      """
      editor.setCursorBufferPosition([5, 3])

      formatText.trigger()
      expect(editor.getText()).toBe """
      text before

      1. aaa
      2. bbb
        a. 11aa
        b. 22bb
          AA. a1
      3. ccc
        1. aaa
          - aaa
        2. bbb
        3. ccc
          1. aaa
            1. aaa
              - aaa
              - bbb
          2. bbb
        4. ddd
      4. ddd
      5. eee

      text after
      """

    it "correct invalid order list numbers", ->
      editor.setText """
      text before

        3. aaa
      9. bbb
        a. 11aa

      text after
      """
      editor.setCursorBufferPosition([3, 1])

      formatText.trigger()
      expect(editor.getText()).toBe """
      text before

        1. aaa
      1. bbb
        a. 11aa

      text after
      """

  describe "formatTable", ->
    beforeEach -> formatText = new FormatText("format-table")

    it "does nothing if it is not a table", ->
      editor.setText """
      text is a long paragraph
      text is a long paragraph
      """
      editor.setCursorBufferPosition([0, 3])

      formatText.trigger()
      expect(editor.getText()).toBe """
      text is a long paragraph
      text is a long paragraph
      """

    it "format table without alignment", ->
      editor.setText """
      text before

      h1| h21|h1233|h343
      -|-
      |||
      t123           | t2
       |t12|

      text after
      """

      expected = """
      text before

      h1   | h21 | h1233 | h343
      -----|-----|-------|-----
           |     |       |
      t123 | t2  |       |
           | t12 |       |

      text after
      """

      editor.setCursorBufferPosition([4, 3])
      formatText.trigger()
      expect(editor.getText()).toBe(expected)

      # trigger twice shouldn't change anything
      editor.setCursorBufferPosition([4, 3])
      formatText.trigger()
      expect(editor.getText()).toBe(expected)

    it "format table with alignment", ->
      editor.setText """
      text before

      |h1-3   | h2-1|h3-2|
      |:-|:-:|--:|:-:|
      | | t2
      |t1| |t3
      |t     |t|    t

      text after
      """

      expected = """
      text before

      | h1-3 | h2-1 | h3-2 |   |
      |:-----|:----:|-----:|:-:|
      |      |  t2  |      |   |
      | t1   |      |   t3 |   |
      | t    |  t   |    t |   |

      text after
      """

      editor.setCursorBufferPosition([4, 3])
      formatText.trigger()
      expect(editor.getText()).toBe(expected)

      # trigger twice shouldn't change anything
      editor.setCursorBufferPosition([4, 3])
      formatText.trigger()
      expect(editor.getText()).toBe(expected)

    it "format table with alignment (trailing spaces)", ->
      editor.setText [
        "| col 1 | col 2 | "
        "| :------ | :----- | "
        "| Item One    | Item Two  | "
      ].join("\n")

      expected = [
        "| col 1    | col 2    |"
        "|:---------|:---------|"
        "| Item One | Item Two |"
      ].join("\n")

      editor.setCursorBufferPosition([2, 3])
      formatText.trigger()
      expect(editor.getText()).toBe(expected)

      # trigger twice shouldn't change anything
      editor.setCursorBufferPosition([1, 5])
      formatText.trigger()
      expect(editor.getText()).toBe(expected)
