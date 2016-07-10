{CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require "atom-space-pen-views"
path = require "path"
fs = require "fs-plus"

config = require "../config"
utils = require "../utils"
templateHelper = require "../helpers/template-helper"

module.exports =
class NewFileView extends View
  @fileType = "File" # override
  @pathConfig = "siteFilesDir" # override
  @fileNameConfig = "newFileFileName" # override

  @content: ->
    @div class: "markdown-writer", =>
      @label "Add New #{@fileType}", class: "icon icon-file-add"
      @div =>
        @label "Directory", class: "message"
        @subview "pathEditor", new TextEditorView(mini: true)
        @label "Date", class: "message"
        @subview "dateEditor", new TextEditorView(mini: true)
        @label "Title", class: "message"
        @subview "titleEditor", new TextEditorView(mini: true)
      @p class: "message", outlet: "message"
      @p class: "error", outlet: "error"

  initialize: ->
    utils.setTabIndex([@titleEditor, @pathEditor, @dateEditor])

    # save current date time as base
    @dateTime = templateHelper.getDateTime()

    @titleEditor.getModel().onDidChange => @updatePath()
    @pathEditor.getModel().onDidChange => @updatePath()
    # update pathEditor to reflect date changes, however this will overwrite user changes
    @dateEditor.getModel().onDidChange =>
      @pathEditor.setText(templateHelper.create(@constructor.pathConfig, @getDateTime()))

    @disposables = new CompositeDisposable()
    @disposables.add(atom.commands.add(
      @element, {
        "core:confirm": => @createFile()
        "core:cancel": => @detach()
      }))

  display: ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @dateEditor.setText(templateHelper.getFrontMatterDate(@dateTime))
    @pathEditor.setText(templateHelper.create(@constructor.pathConfig, @dateTime))
    @panel.show()
    @titleEditor.focus()

  detach: ->
    if @panel.isVisible()
      @panel.hide()
      @previouslyFocusedElement?.focus()
    super

  detached: ->
    @disposables?.dispose()
    @disposables = null

  createFile: ->
    try
      filePath = path.join(@getFileDir(), @getFilePath())

      if fs.existsSync(filePath)
        @error.text("File #{filePath} already exists!")
      else
        frontMatterText = templateHelper.create("frontMatter", @getFrontMatter(), @getDateTime())
        fs.writeFileSync(filePath, frontMatterText)
        atom.workspace.open(filePath)
        @detach()
    catch error
      @error.text("#{error.message}")

  updatePath: ->
    @message.html """
    <b>Site Directory:</b> #{@getFileDir()}<br/>
    <b>Create #{@constructor.fileType} At:</b> #{@getFilePath()}
    """

  # common interface for FrontMatter
  getLayout: -> "post"
  getPublished: -> @constructor.fileType == "Post"
  getTitle: -> @titleEditor.getText() || "New #{@constructor.fileType}"
  getSlug: -> utils.slugize(@getTitle(), config.get('slugSeparator'))
  getDate: -> templateHelper.getFrontMatterDate(@getDateTime())
  getExtension: -> config.get("fileExtension")

  # new file and front matters
  getFileDir: -> utils.getSitePath(config.get("siteLocalDir"))
  getFilePath: -> path.join(@pathEditor.getText(), @getFileName())

  getFileName: -> templateHelper.create(@constructor.fileNameConfig, @getFrontMatter(), @getDateTime())
  getDateTime: -> templateHelper.parseFrontMatterDate(@dateEditor.getText()) || @dateTime
  getFrontMatter: -> templateHelper.getFrontMatter(this)
