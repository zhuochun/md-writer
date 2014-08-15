utils = require "./utils"
path = require "path"
fs = require "fs-plus"

module.exports =
class PublishDraft
  draftPath: null
  postPath: null
  frontMatter: null
  editor: null

  constructor: ->
    @editor = atom.workspace.getActiveEditor()
    @draftPath = @editor.getPath()
    @frontMatter = utils.getFrontMatter(@editor.getText())
    @postPath = @getPostPath()

  display: ->
    @updateFrontMatter()
    atom.workspaceView.destroyActivePaneItem()
    @publishDraft()
    atom.workspaceView.open(@postPath)

  updateFrontMatter: ->
    @frontMatter.published = true if @frontMatter.published?
    @frontMatter.date = "#{utils.getDateStr()} #{utils.getTimeStr()}"
    @editor.buffer.scan utils.frontMatterRegex, (match) =>
      match.replace utils.getFrontMatterText(@frontMatter)
    atom.workspaceView.saveActivePaneItem()

  publishDraft: ->
    try
      if fs.existsSync(@postPath)
        alert("Error:\nPost #{@postPath} already exists!")
      else
        fs.renameSync(@draftPath, @postPath)
    catch error
      alert("Error:\n#{error.message}")

  getPostPath: ->
    path.join(@getPostDir(), @getPostName())

  getPostDir: ->
    localDir = atom.config.get("markdown-writer.siteLocalDir")
    postsDir = atom.config.get("markdown-writer.sitePostsDir")
    postsDir = utils.dirTemplate(postsDir) # replace tokens
    return path.join(localDir, postsDir)

  getPostName: ->
    date = utils.getDateStr()
    title = @getPostTitle()
    extension = @getPostExtension()
    return "#{date}-#{title}#{extension}"

  getPostTitle: ->
    if atom.config.get("markdown-writer.publishRenameBasedOnTitle")
      title = utils.dasherize(@frontMatter.title)
    return title || path.basename(@draftPath, path.extname(@draftPath))

  getPostExtension: ->
    if atom.config.get("markdown-writer.publishKeepFileExtname")
      extname = path.extname(@draftPath)
    return extname || atom.config.get("markdown-writer.fileExtension")
