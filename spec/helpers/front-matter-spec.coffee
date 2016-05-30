FrontMatter = require "../../lib/helpers/front-matter"

describe "FrontMatter", ->
  beforeEach ->
    waitsForPromise -> atom.workspace.open("front-matter.markdown")

  describe "editor without front matter", ->
    editor = null

    beforeEach ->
      editor = atom.workspace.getActiveTextEditor()

    it "is empty when editor is empty", ->
      frontMatter = new FrontMatter(editor)
      expect(frontMatter.isEmpty).toBe(true)
      expect(frontMatter.content).toEqual({})

    it "is empty when editor has no front matter", ->
      editor.setText """
        some random text 1
        some random text 2
      """

      frontMatter = new FrontMatter(editor)
      expect(frontMatter.isEmpty).toBe(true)
      expect(frontMatter.content).toEqual({})

    it "is empty when editor has invalid front matter", ->
      editor.setText """
        ---
        ---

        some random text 1
        some random text 2
      """

      frontMatter = new FrontMatter(editor)
      expect(frontMatter.isEmpty).toBe(true)
      expect(frontMatter.content).toEqual({})

  describe "editor with jekyll front matter", ->
    [editor, frontMatter] = []

    beforeEach ->
      editor = atom.workspace.getActiveTextEditor()
      editor.setText """
        ---
        title: Markdown Writer (Jekyll)
        date: 2015-08-12 23:19
        categories: Markdown
        tags:
          - Writer
          - Jekyll
        ---

        some random text 1
        some random text 2
      """

      frontMatter = new FrontMatter(editor)

    it "is not empty", ->
      expect(frontMatter.isEmpty).toBe(false)

    it "has fields", ->
      expect(frontMatter.has("title")).toBe(true)
      expect(frontMatter.has("date")).toBe(true)
      expect(frontMatter.has("categories")).toBe(true)
      expect(frontMatter.has("tags")).toBe(true)

    it "get field value", ->
      expect(frontMatter.get("title")).toBe("Markdown Writer (Jekyll)")
      expect(frontMatter.get("date")).toBe("2015-08-12 23:19")

    it "set field value", ->
      frontMatter.set("title", "Markdown Writer")
      expect(frontMatter.get("title")).toBe("Markdown Writer")

    it "normalize field to an array", ->
      expect(frontMatter.normalizeField("field")).toEqual([])
      expect(frontMatter.normalizeField("categories")).toEqual(["Markdown"])
      expect(frontMatter.normalizeField("tags")).toEqual(["Writer", "Jekyll"])

    it "get content text with leading fence", ->
      expect(frontMatter.getContentText()).toBe """
        ---
        title: Markdown Writer (Jekyll)
        date: '2015-08-12 23:19'
        categories: Markdown
        tags:
          - Writer
          - Jekyll
        ---

      """

    it "save the content to editor", ->
      frontMatter.save()

      expect(editor.getText()).toBe """
        ---
        title: Markdown Writer (Jekyll)
        date: '2015-08-12 23:19'
        categories: Markdown
        tags:
          - Writer
          - Jekyll
        ---

        some random text 1
        some random text 2
      """

  describe "editor with hexo front matter", ->
    [editor, frontMatter] = []

    beforeEach ->
      editor = atom.workspace.getActiveTextEditor()
      editor.setText """
        title: Markdown Writer (Hexo)
        date: 2015-08-12 23:19
        ---

        some random text 1
        some random text 2
      """
      frontMatter = new FrontMatter(editor)

    it "is not empty", ->
      expect(frontMatter.isEmpty).toBe(false)

    it "has field title/date", ->
      expect(frontMatter.has("title")).toBe(true)
      expect(frontMatter.has("date")).toBe(true)

    it "get field value", ->
      expect(frontMatter.get("title")).toBe("Markdown Writer (Hexo)")
      expect(frontMatter.get("date")).toBe("2015-08-12 23:19")

    it "get content text without leading fence", ->
      expect(frontMatter.getContentText()).toBe """
        title: Markdown Writer (Hexo)
        date: '2015-08-12 23:19'
        ---

      """
