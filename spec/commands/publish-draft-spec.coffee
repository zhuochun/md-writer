path = require "path"
PublishDraft = require "../../lib/commands/publish-draft"

pathSep = "[/\\\\]"

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

      expect(publishDraft.draftPath).toMatch(/// #{pathSep}fixtures#{pathSep}empty\.markdown$ ///)
      expect(publishDraft.postPath).toMatch(/// #{pathSep}\d{4}#{pathSep}\d{4}-\d\d-\d\d-empty\.markdown$ ///)

  describe ".getSlug", ->
    it "get title from front matter by config", ->
      atom.config.set("markdown-writer.publishRenameBasedOnTitle", true)
      editor.setText """
      ---
      title: Markdown Writer
      ---
      """

      publishDraft = new PublishDraft({})
      expect(publishDraft.getSlug()).toBe("markdown-writer")

    it "get title from front matter if no draft path", ->
      editor.setText """
      ---
      title: Markdown Writer (New Post)
      ---
      """

      publishDraft = new PublishDraft({})
      publishDraft.draftPath = undefined
      expect(publishDraft.getSlug()).toBe("markdown-writer-new-post")

    it "get title from draft path", ->
      publishDraft = new PublishDraft({})
      publishDraft.draftPath = path.join("test", "name-of-post.md")
      expect(publishDraft.getSlug()).toBe("name-of-post")

    it "get new-post when no front matter/draft path", ->
      publishDraft = new PublishDraft({})
      publishDraft.draftPath = undefined
      expect(publishDraft.getSlug()).toBe("new-post")

  describe ".getExtension", ->
    beforeEach -> publishDraft = new PublishDraft({})

    it "get draft path extname by config", ->
      atom.config.set("markdown-writer.publishKeepFileExtname", true)
      publishDraft.draftPath = path.join("test", "name.md")
      expect(publishDraft.getExtension()).toBe(".md")

    it "get default extname", ->
      publishDraft.draftPath = path.join("test", "name.md")
      expect(publishDraft.getExtension()).toBe(".markdown")
