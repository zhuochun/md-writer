{$} = require "atom-space-pen-views"
fs = require "fs-plus"
path = require "path"
shell = require "shell"

config = require "../config"
utils = require "../utils"
FrontMatter = require "../helpers/front-matter"

module.exports =
class PublishDraft
  constructor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @frontMatter = new FrontMatter(@editor)

  trigger: (e) ->
    @updateFrontMatter()

    @draftPath = @editor.getPath()
    @postPath = @getPostPath()

    @confirmPublish =>
      try
        @editor.saveAs(@postPath)
        shell.moveItemToTrash(@draftPath) if @draftPath
      catch error
        atom.confirm
          message: "[Markdown Writer] Error!"
          detailedMessage: "Publish Draft:\n#{error.message}"
          buttons: ['OK']

  confirmPublish: (callback) ->
    if fs.existsSync(@postPath)
      atom.confirm
        message: "Do you want to overwrite file?"
        detailedMessage: "Another file already exists at:\n#{@postPath}"
        buttons:
          "Confirm": callback
          "Cancel": null
    else if @draftPath == @postPath
      atom.confirm
        message: "This file is published!"
        detailedMessage: "This file already published at:\n#{@draftPath}"
        buttons: ['OK']
    else callback()

  updateFrontMatter: ->
    return if @frontMatter.isEmpty

    @frontMatter.setIfExists("published", true)
    @frontMatter.setIfExists("date", "#{utils.getDateStr()} #{utils.getTimeStr()}")

    @frontMatter.save()

  getPostPath: ->
    localDir = config.get("siteLocalDir") || utils.getProjectPath()
    postsDir = utils.dirTemplate(config.get("sitePostsDir"))

    path.join(localDir, postsDir, @_getPostName())

  _getPostName: ->
    template = config.get("newPostFileName")

    date = utils.getDate()
    info =
      title: @_getPostTitle()
      extension: @_getPostExtension()

    utils.template(template, $.extend(info, date))

  _getPostTitle: ->
    useFrontMatter = !@draftPath || !!config.get("publishRenameBasedOnTitle")
    title = utils.dasherize(@frontMatter.get("title")) if useFrontMatter
    title || utils.getTitleSlug(@draftPath) || utils.dasherize("New Post")

  _getPostExtension: ->
    extname = path.extname(@draftPath) if !!config.get("publishKeepFileExtname")
    extname || config.get("fileExtension")
