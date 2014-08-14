{$, View, EditorView} = require "atom"
utils = require "./utils"
remote = require "remote"
dialog = remote.require "dialog"
path = require "path"
fs = require "fs-plus"

imageExtensions = [".jpg", ".png", ".gif"]

module.exports =
class InsertImageView extends View
  editor: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog overlay from-top", =>
      @label "Insert Image", class: "icon icon-link"
      @div =>
        @label "Image Path", class: "message"
        @subview "imgEditor", new EditorView(mini: true)
        @div =>
          @button "Choose Local Image", outlet: "openImg", class: "btn"
          @label outlet: "message", class: "side-label"
        @label "Title", class: "message"
        @subview "titleEditor", new EditorView(mini: true)
        @label "Width", class: "message"
        @subview "widthEditor", new EditorView(mini: true)
        @label "Height", class: "message"
        @subview "heightEditor", new EditorView(mini: true)
      @div class: "image-container", =>
        @img outlet: 'image'

  initialize: ->
    @handleEvents()
    @on "core:confirm", => @onConfirm()
    @on "core:cancel", => @detach()

  handleEvents: ->
    @imgEditor.hiddenInput.on "focusout", => @setImage(@imgEditor.getText())
    @openImg.on "click", => @openImageDialog()

  onConfirm: ->
    imgPath = @imgEditor.getText()
    imgTitle = @titleEditor.getText()
    if @isValidImageFile(imgPath)
      @editor.insertText("![#{imgTitle}][#{imgPath}]")
    @detach()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()
    atom.workspaceView.append(this)
    @imgEditor.focus()

  openImageDialog: ->
    files = dialog.showOpenDialog(properties: ['openFile'])
    return unless files

    file = files[0]
    if @isValidImageFile(file)
      @imgEditor.setText(file)
      @setImage(file)
      @message.text("Image: #{@imageWidth} x #{@imageHeight}")
    else
      @message.text("Error: Invalid Image File.")

  setImage: (file) ->
    return unless @isValidImageFile(file)
    @imageSrc = file
    @image.attr("src", file)
    @image.load =>
      @imageWidth = @image.context.naturalWidth
      @imageHeight = @image.context.naturalHeight

  moveLocalImage: (file) ->
    return unless isLocalImageFile(file)

  isValidImageFile: (file) ->
    path.extname(file) in imageExtensions
