{$} = require "atom"
fs = require "fs-plus"
path = require "path"
utils = require "./utils"

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
    postsDir = utils.dirTemplate(postsDir)
    return path.join(localDir, postsDir)

  getPostName: ->
    template = atom.config.get("markdown-writer.newPostFileName")
    date = utils.getDate()
    info =
      title: @getPostTitle()
      extension: @getPostExtension()
    return utils.template(template, $.extend(info, date))

  getPostTitle: ->
    if atom.config.get("markdown-writer.publishRenameBasedOnTitle")
      title = utils.dasherize(@frontMatter.title)
    else
      title = path.basename(@draftPath, path.extname(@draftPath))

      # remove date prefix if any
      if matches = /^(\d{1,4}-\d{1,2}-\d{1,4}-)(.+)$/.exec(title)
        title = matches[2]

    return title

  getPostExtension: ->
    if atom.config.get("markdown-writer.publishKeepFileExtname")
      extname = path.extname(@draftPath)
    return extname || atom.config.get("markdown-writer.fileExtension")
