PublishDraft = require "../../lib/commands/publish-draft"

describe "PublishDraft", ->
  [editor, publishDraft] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")
    runs -> editor = atom.workspace.getActiveTextEditor()

  describe ".trigger", ->
    it "abort publish draft when not confirm publish", ->
      publishDraft = new PublishDraft({})
      publishDraft.confirmPublish = -> {} # Double confirmPublish

      publishDraft.trigger()

      expect(publishDraft.draftPath).toMatch("fixtures/empty.markdown")
      expect(publishDraft.postPath).toMatch(/\/\d{4}\/\d{4}-\d\d-\d\d-empty\.markdown/)

  describe "._getPostSlug", ->
    it "get title from front matter by config", ->
      atom.config.set("markdown-writer.publishRenameBasedOnTitle", true)
      editor.setText """
      ---
      title: Markdown Writer
      ---
      """

      publishDraft = new PublishDraft({})
      expect(publishDraft._getPostSlug()).toBe("markdown-writer")

    it "get title from front matter if no draft path", ->
      editor.setText """
      ---
      title: Markdown Writer (New Post)
      ---
      """

      publishDraft = new PublishDraft({})
      expect(publishDraft._getPostSlug()).toBe("markdown-writer-new-post")

    it "get title from draft path", ->
      publishDraft = new PublishDraft({})
      publishDraft.draftPath = "test/name-of-post.md"
      expect(publishDraft._getPostSlug()).toBe("name-of-post")

    it "get new-post when no front matter/draft path", ->
      publishDraft = new PublishDraft({})
      expect(publishDraft._getPostSlug()).toBe("new-post")

  describe "._getPostExtension", ->
    beforeEach -> publishDraft = new PublishDraft({})

    it "get draft path extname by config", ->
      atom.config.set("markdown-writer.publishKeepFileExtname", true)
      publishDraft.draftPath = "test/name.md"
      expect(publishDraft._getPostExtension()).toBe(".md")

    it "get default extname", ->
      publishDraft.draftPath = "test/name.md"
      expect(publishDraft._getPostExtension()).toBe(".markdown")
