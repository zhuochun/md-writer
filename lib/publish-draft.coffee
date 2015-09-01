{$} = require "atom-space-pen-views"
FrontMatter = require "./front-matter"
config = require "./config"
utils = require "./utils"
fs = require "fs-plus"
path = require "path"

module.exports =
class PublishDraft
  constructor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @frontMatter = new FrontMatter(@editor)
    @draftPath = @editor.getPath()
    @postPath = @getPostPath()

  display: ->
    @updateFrontMatter()
    @editor.save()

    unless @draftPath == @postPath
      @editor.destroy()
      @moveDraft()
      atom.workspace.open(@postPath)

  updateFrontMatter: ->
    return if @frontMatter.isEmpty

    @frontMatter.setIfExists("published", true)
    @frontMatter.setIfExists("date",
      "#{utils.getDateStr()} #{utils.getTimeStr()}")

    @frontMatter.save()

  moveDraft: ->
    try
      fs.moveSync(@draftPath, @postPath)
    catch error
      alert("Error:\n#{error.message}")

  getPostPath: ->
    path.join(@getPostDir(), @getPostName())

  getPostDir: ->
    localDir = config.get("siteLocalDir")
    postsDir = config.get("sitePostsDir")
    postsDir = utils.dirTemplate(postsDir)

    path.join(localDir, postsDir)

  getPostName: ->
    template = config.get("newPostFileName")

    date = utils.getDate()
    info =
      title: @getPostTitle()
      extension: @getPostExtension()

    utils.template(template, $.extend(info, date))

  getPostTitle: ->
    if config.get("publishRenameBasedOnTitle")
      utils.dasherize(@frontMatter.title)
    else
      utils.getTitleSlug(@draftPath)

  getPostExtension: ->
    extname = path.extname(@draftPath) if config.get("publishKeepFileExtname")
    extname || config.get("fileExtension")
