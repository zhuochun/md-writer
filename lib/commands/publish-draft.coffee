{$} = require "atom-space-pen-views"
fs = require "fs-plus"
path = require "path"
shell = require "shell"

config = require "../config"
utils = require "../utils"
templateHelper = require "../helpers/template-helper"
FrontMatter = require "../helpers/front-matter"

module.exports =
class PublishDraft
  constructor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @draftPath = @editor.getPath()
    @frontMatter = new FrontMatter(@editor)
    @dateTime = templateHelper.getDateTime()

  trigger: (e) ->
    @updateFrontMatter()

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
    @frontMatter.setIfExists("date", templateHelper.getFrontMatterDate(@dateTime))

    @frontMatter.save()

  getPostPath: ->
    frontMatter= templateHelper.getFrontMatter(this)

    localDir = utils.getSitePath(config.get("siteLocalDir"))
    postsDir = templateHelper.create("sitePostsDir", frontMatter, @dateTime)
    fileName = templateHelper.create("newPostFileName", frontMatter, @dateTime)

    path.join(localDir, postsDir, fileName)

  # common interface for FrontMatter
  getLayout: -> @frontMatter.get("layout")
  getPublished: -> @frontMatter.get("published")
  getTitle: -> @frontMatter.get("title")
  getSlug: ->
    # derive slug from front matters if current file is not saved (not having a path), or
    # configured to rename base on title or the file path doen't exists.
    useFrontMatter = !@draftPath || !!config.get("publishRenameBasedOnTitle")
    slug = utils.slugize(@frontMatter.get("title"), config.get('slugSeparator')) if useFrontMatter
    slug || templateHelper.getFileSlug(@draftPath) || utils.slugize("New Post", config.get('slugSeparator'))
  getDate: -> templateHelper.getFrontMatterDate(@dateTime)
  getExtension: ->
    # keep file extension if path exists and has configured to keep it.
    keepExtension = @draftPath && !!config.get("publishKeepFileExtname")
    extname = path.extname(@draftPath) if keepExtension
    extname || config.get("fileExtension")
