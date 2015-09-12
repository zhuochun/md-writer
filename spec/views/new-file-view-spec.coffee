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
        atom.config.set("markdown-writer.newFileFileName", "file-{title}{extension}")
        atom.config.set("markdown-writer.fileExtension", ".md")

        newFileView.titleEditor.setText("Hexo format")
        newFileView.dateEditor.setText("2014-11-19")

        expect(newFileView.getFileName()).toBe("file-hexo-format.md")

    describe '.generateFrontMatter', ->
      it "generate correctly", ->
        frontMatter =
          layout: "test", title: "the actual title", date: "2014-11-19"

        expect(newFileView.generateFrontMatter(frontMatter)).toBe """
        ---
        layout: test
        title: "the actual title"
        date: "2014-11-19"
        ---
        """

      it "generate based on setting", ->
        frontMatter =
          layout: "test", title: "the actual title", date: "2014-11-19"

        atom.config.set("markdown-writer.frontMatter", "title: <title>")

        expect(newFileView.generateFrontMatter(frontMatter)).toBe(
          "title: the actual title")


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

        newDraftView.dateEditor.setText("2015-08-23")
        newDraftView.titleEditor.setText("Draft Title")

        expect(newDraftView.message.text()).toBe """
        Site Directory: /config/your/local/directory/in/settings/
        Create Draft At: _drafts/draft-title.markdown
        """

    describe ".getFrontMatter", ->
      it "get the correct front matter", ->
        newDraftView.dateEditor.setText("2015-08-23")
        newDraftView.titleEditor.setText("Draft Title")

        frontMatter = newDraftView.getFrontMatter()
        expect(frontMatter.layout).toBe("post")
        expect(frontMatter.published).toBe(false)
        expect(frontMatter.title).toBe("Draft Title")
        expect(frontMatter.slug).toBe("draft-title")

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

        newPostView.dateEditor.setText("2015-08-23")
        newPostView.titleEditor.setText("Post's Title")

        expect(newPostView.message.text()).toBe """
        Site Directory: /config/your/local/directory/in/settings/
        Create Post At: _posts/2015/2015-08-23-posts-title.markdown
        """

    describe ".getFrontMatter", ->
      it "get the correct front matter", ->
        newPostView.dateEditor.setText("2015-08-24")
        newPostView.titleEditor.setText("Post's Title: Subtitle")

        frontMatter = newPostView.getFrontMatter()
        expect(frontMatter.layout).toBe("post")
        expect(frontMatter.published).toBe(true)
        expect(frontMatter.title).toBe("Post's Title: Subtitle")
        expect(frontMatter.slug).toBe("posts-title-subtitle")
