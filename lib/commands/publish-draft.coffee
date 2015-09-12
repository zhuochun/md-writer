{$} = require "atom-space-pen-views"
fs = require "fs-plus"
path = require "path"

config = require "../config"
utils = require "../utils"
FrontMatter = require "../helpers/front-matter"

module.exports =
class PublishDraft
  constructor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @frontMatter = new FrontMatter(@editor)

  display: ->
    @updateFrontMatter()
    @editor.save()

    @draftPath = @editor.getPath()
    @postPath = @getPostPath()

    @moveDraft() unless @draftPath == @postPath

  updateFrontMatter: ->
    return if @frontMatter.isEmpty

    @frontMatter.setIfExists("published", true)
    @frontMatter.setIfExists("date",
      "#{utils.getDateStr()} #{utils.getTimeStr()}")

    @frontMatter.save()

  moveDraft: ->
    try
      @editor.destroy()
      fs.moveSync(@draftPath, @postPath)
      atom.workspace.open(@postPath)
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
