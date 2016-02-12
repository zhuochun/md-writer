path = require "path"
NewFileView = require "../../lib/views/new-file-view"
NewDraftView = require "../../lib/views/new-draft-view"
NewPostView = require "../../lib/views/new-post-view"

describe "NewFileView", ->
  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")

  describe "NewFileView", ->
    newFileView = null

    beforeEach ->
      newFileView = new NewFileView({})

    describe '.getFileName', ->
      it "get filename in hexo format", ->
        atom.config.set("markdown-writer.newFileFileName", "file-{slug}{extension}")
        atom.config.set("markdown-writer.fileExtension", ".md")

        newFileView.titleEditor.setText("Hexo format")
        expect(newFileView.getFileName()).toBe("file-hexo-format.md")

  describe "NewDraftView", ->
    newDraftView = null

    beforeEach ->
      newDraftView = new NewDraftView({})

    describe "class methods", ->
      it "override correctly", ->
        expect(NewDraftView.fileType).toBe("Draft")
        expect(NewDraftView.pathConfig).toBe("siteDraftsDir")
        expect(NewDraftView.fileNameConfig).toBe("newDraftFileName")

    describe ".display", ->
      it 'display correct message', ->
        newDraftView.display()

        newDraftView.dateEditor.setText("2015-08-23 11:19")
        newDraftView.titleEditor.setText("Draft Title")

        expect(newDraftView.message.text()).toBe """
        Site Directory: #{atom.project.getPaths()[0]}
        Create Draft At: #{path.join("_drafts", "draft-title.markdown")}
        """

    describe ".getFrontMatter", ->
      it "get the correct front matter", ->
        newDraftView.dateEditor.setText("2015-08-23 11:19")
        newDraftView.titleEditor.setText("Draft Title")

        frontMatter = newDraftView.getFrontMatter()
        expect(frontMatter.layout).toBe("post")
        expect(frontMatter.published).toBe(false)
        expect(frontMatter.title).toBe("Draft Title")
        expect(frontMatter.slug).toBe("draft-title")
        expect(frontMatter.date).toBe("2015-08-23 11:19")

  describe "NewPostView", ->
    newPostView = null

    beforeEach ->
      newPostView = new NewPostView({})

    describe "class methods", ->
      it "override correctly", ->
        expect(NewPostView.fileType).toBe("Post")
        expect(NewPostView.pathConfig).toBe("sitePostsDir")
        expect(NewPostView.fileNameConfig).toBe("newPostFileName")

    describe ".display", ->
      it 'display correct message', ->
        newPostView.display()

        newPostView.dateEditor.setText("2015-08-23 11:19")
        newPostView.titleEditor.setText("Post's Title")

        expect(newPostView.message.text()).toBe """
        Site Directory: #{atom.project.getPaths()[0]}
        Create Post At: #{path.join("_posts", "2015", "2015-08-23-post-s-title.markdown")}
        """

    describe ".getFrontMatter", ->
      it "get the correct front matter", ->
        newPostView.dateEditor.setText("2015-08-24 11:19")
        newPostView.titleEditor.setText("Post's Title: Subtitle")

        frontMatter = newPostView.getFrontMatter()
        expect(frontMatter.layout).toBe("post")
        expect(frontMatter.published).toBe(true)
        expect(frontMatter.title).toBe("Post's Title: Subtitle")
        expect(frontMatter.slug).toBe("post-s-title-subtitle")
        expect(frontMatter.date).toBe("2015-08-24 11:19")
