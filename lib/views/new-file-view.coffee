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
        # render custom fields
        for f in @getCustomFields()
          @label f["name"], class: "message"
          @subview f["editor"], new TextEditorView(mini: true)

      @p class: "message", outlet: "message"
      @p class: "error", outlet: "error"

  # custom fields
  @getCustomFields: ->
    for field, value of config.get("frontMatterCustomFields") || {}
      id: utils.slugize(field)
      editor: "#{utils.slugize(field)}CustomEditor"
      name: utils.capitalize(field)
      value: value

  initialize: ->
    editors = [@titleEditor, @pathEditor, @dateEditor]
    editors.push(@[f["editor"]]) for f in @constructor.getCustomFields()
    # set tab orders
    utils.setTabIndex(editors)

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
    @[f["editor"]].setText(f["value"]) for f in @constructor.getCustomFields() when !!f["value"]
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
  getFileDir: ->
    filePath = atom.workspace.getActiveTextEditor()?.getPath() # Nullable
    utils.getSitePath(config.get("siteLocalDir"), filePath)
  getFilePath: -> path.join(@pathEditor.getText(), @getFileName())

  getFileName: -> templateHelper.create(@constructor.fileNameConfig, @getFrontMatter(), @getDateTime())
  getDateTime: -> templateHelper.parseFrontMatterDate(@dateEditor.getText()) || @dateTime
  getFrontMatter: ->
    base = templateHelper.getFrontMatter(this)
    # add custom fields to frontMatter
    base[f["id"]] = @[f["editor"]].getText() for f in @constructor.getCustomFields()
    base
