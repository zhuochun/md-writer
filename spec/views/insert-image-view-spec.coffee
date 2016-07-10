config = require "../../lib/config"
InsertImageView = require "../../lib/views/insert-image-view"

describe "InsertImageView", ->
  [editor, insertImageView] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      insertImageView = new InsertImageView({})

  describe ".isInSiteDir", ->
    beforeEach ->
      atom.config.set("markdown-writer.siteLocalDir", editor.getPath().replace("empty.markdown", ""))

    it "check a file is in site local dir", ->
      fixture = "#{config.get("siteLocalDir")}/image.jpg"
      expect(insertImageView.isInSiteDir(fixture)).toBe(true)

    it "check a file is not in site local dir", ->
      fixture = 'some/random/path/image.jpg'
      expect(insertImageView.isInSiteDir(fixture)).toBe(false)

  describe ".resolveImagePath", ->
    it "return empty image path", ->
      fixture = ""
      expect(insertImageView.resolveImagePath(fixture)).toBe(fixture)

    it "return URL image path", ->
      fixture = "https://assets-cdn.github.com/images/icons/emoji/octocat.png"
      expect(insertImageView.resolveImagePath(fixture)).toBe(fixture)

    it "return relative image path", ->
      insertImageView.editor = editor
      fixture = editor.getPath().replace("empty.markdown", "octocat.png")
      expect(insertImageView.resolveImagePath(fixture)).toBe(fixture)

    it "return absolute image path", ->
      insertImageView.editor = editor
      atom.config.set("markdown-writer.siteLocalDir", editor.getPath().replace("empty.markdown", ""))

      fixture = "octocat.png"
      expected = editor.getPath().replace("empty.markdown", "octocat.png")
      expect(insertImageView.resolveImagePath(fixture)).toBe(expected)

  describe ".copyImageDestPath", ->
    it "return the local path with original filename", ->
      atom.config.set("markdown-writer.renameImageOnCopy", false)
      fixture = "images/icons/emoji/octocat.png"
      expect(insertImageView.copyImageDestPath(fixture, "name")).toMatch(/[\/\\]octocat\.png/)

    it "return the local path with new filename", ->
      atom.config.set("markdown-writer.renameImageOnCopy", true)
      # normal case
      fixture = "images/icons/emoji/octocat.png"
      expect(insertImageView.copyImageDestPath(fixture, "New name")).toMatch(/[\/\\]new-name\.png/)
      # no extension
      fixture = "images/icons/emoji/octocat"
      expect(insertImageView.copyImageDestPath(fixture, "New name")).toMatch(/[\/\\]new-name/)
      # no alt text set
      fixture = "images/icons/emoji/octocat.png"
      expect(insertImageView.copyImageDestPath(fixture, "")).toMatch(/[\/\\]octocat.png/)

  describe ".generateImageSrc", ->
    it "return empty image path", ->
      fixture = ""
      expect(insertImageView.generateImageSrc(fixture)).toBe(fixture)

    it "return URL image path", ->
      fixture = "https://assets-cdn.github.com/images/icons/emoji/octocat.png"
      expect(insertImageView.generateImageSrc(fixture)).toBe(fixture)

    it "return relative image path from file", ->
      insertImageView.editor = editor
      atom.config.set("markdown-writer.relativeImagePath", true)

      fixture = editor.getPath().replace("empty.markdown", "octocat.png")
      expect(insertImageView.generateImageSrc(fixture)).toBe("octocat.png")

    it "return relative image path from site", ->
      atom.config.set("markdown-writer.siteLocalDir", "/assets/images/icons/emoji")

      fixture = "/assets/images/icons/emoji/octocat.png"
      expect(insertImageView.generateImageSrc(fixture)).toBe("octocat.png")

    it "return image dir path using config template", ->
      insertImageView.display()
      fixture = "octocat.png"
      expected = /// ^ \/images\/\d{4}\/\d\d\/octocat\.png $ ///
      expect(insertImageView.generateImageSrc(fixture)).toMatch(expected)
