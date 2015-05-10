{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"
remote = require "remote"
dialog = remote.require "dialog"
path = require "path"
fs = require "fs-plus"

imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".ico"]
lastInsertImageDir = null # remember last inserted image directory

module.exports =
class InsertImageView extends View
  imageOnPreview: ""
  editor: null
  range: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog", =>
      @label "Insert Image", class: "icon icon-device-camera"
      @div =>
        @label "Image Path (src)", class: "message"
        @subview "imageEditor", new TextEditorView(mini: true)
        @div class: "dialog-row", =>
          @button "Choose Local Image", outlet: "openImageButton", class: "btn"
          @label outlet: "message", class: "side-label"
        @label "Title (alt)", class: "message"
        @subview "titleEditor", new TextEditorView(mini: true)
        @div class: "col-1", =>
          @label "Width (px)", class: "message"
          @subview "widthEditor", new TextEditorView(mini: true)
        @div class: "col-1", =>
          @label "Height (px)", class: "message"
          @subview "heightEditor", new TextEditorView(mini: true)
        @div class: "col-2", =>
          @label "Alignment", class: "message"
          @subview "alignEditor", new TextEditorView(mini: true)
      @div outlet: "copyImagePanel", class: "hidden dialog-row", =>
        @label for: "markdown-writer-copy-image-checkbox", =>
          @input id: "markdown-writer-copy-image-checkbox",
            type:"checkbox", outlet: "copyImageCheckbox"
          @span "Copy Image to Site Image Directory", class: "side-label"
      @div class: "image-container", =>
        @img outlet: 'imagePreview'

  initialize: ->
    @imageEditor.on "blur", => @updateImageSource(@imageEditor.getText().trim())
    @openImageButton.on "click", => @openImageDialog()

    atom.commands.add @element,
      "core:confirm": => @onConfirm()
      "core:cancel":  => @detach()

  onConfirm: ->
    imgUrl = @imageEditor.getText().trim()
    return unless imgUrl

    callback = => @insertImage(); @detach()
    if @copyImageCheckbox.prop("checked")
      @copyImage(@resolveImageUrl(imgUrl), callback)
    else
      callback()

  insertImage: ->
    img =
      src: @generateImageUrl(@imageEditor.getText().trim())
      alt: @titleEditor.getText()
      width: @widthEditor.getText()
      height: @heightEditor.getText()
      align: @alignEditor.getText()
      slug: utils.getTitleSlug(@editor.getPath())
      site: config.get("siteUrl")
    text = if img.src then @generateImageTag(img) else img.alt
    @editor.setTextInBufferRange(@range, text)

  copyImage: (file, callback) ->
    return callback() if utils.isUrl(file) || !fs.existsSync(file)

    try
      destFile = path.join(config.get("siteLocalDir"),
        @imagesDir(), path.basename(file))

      if fs.existsSync(destFile)
        alert("Error:\nImage #{destPath} already exists!")
      else
        fs.copy file, destFile, =>
          @imageEditor.setText(destFile)
          callback()
    catch error
      alert("Error:\n#{error.message}")

  display: ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActiveTextEditor()
    @setFieldsFromSelection()
    @panel.show()
    @imageEditor.focus()

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

  setFieldsFromSelection: ->
    @range = utils.getSelectedTextBufferRange(@editor, "link")
    selection = @editor.getTextInRange(@range)
    @_setFieldsFromSelection(selection) if selection

  _setFieldsFromSelection: (selection) ->
    if utils.isImage(selection)
      img = utils.parseImage(selection)
    else if utils.isImageTag(selection)
      img = utils.parseImageTag(selection)
    else
      img = { alt: selection }

    @titleEditor.setText(img.alt || "")
    @widthEditor.setText(img.width || "")
    @heightEditor.setText(img.height || "")
    @imageEditor.setText(img.src || "")
    @updateImageSource(img.src)

  openImageDialog: ->
    files = dialog.showOpenDialog
      properties: ['openFile']
      defaultPath: lastInsertImageDir || atom.project.getPaths()[0]
    return unless files
    lastInsertImageDir = path.dirname(files[0])
    @imageEditor.setText(files[0])
    @updateImageSource(files[0])
    @titleEditor.focus()

  updateImageSource: (file) ->
    return unless file

    @displayImagePreview(file)
    if utils.isUrl(file) || @isInSiteDir(@resolveImageUrl(file))
      @copyImagePanel.addClass("hidden")
    else
      @copyImagePanel.removeClass("hidden")

  displayImagePreview: (file) ->
    return if @imageOnPreview == file

    if @isValidImageFile(file)
      @message.text("Opening Image Preview ...")
      @imagePreview.attr("src", @resolveImageUrl(file))
      @imagePreview.load => @setImageContext(); @message.text("")
      @imagePreview.error =>
        @message.text("Error: Failed to Load Image.")
        @imagePreview.attr("src", "")
    else
      @message.text("Error: Invalid Image File.") if file
      @imagePreview.attr("src", "")
      @widthEditor.setText("")
      @heightEditor.setText("")
      @alignEditor.setText("")

    @imageOnPreview = file # cache preview image src

  isValidImageFile: (file) ->
    file && (path.extname(file).toLowerCase() in imageExtensions)

  setImageContext: ->
    { naturalWidth, naturalHeight } = @imagePreview.context
    @widthEditor.setText("" + naturalWidth)
    @heightEditor.setText("" + naturalHeight)

    position = if naturalWidth > 300 then "center" else "right"
    @alignEditor.setText(position)

  isInSiteDir: (file) -> file && file.startsWith(config.get("siteLocalDir"))

  imagesDir: -> utils.dirTemplate(config.get("siteImagesDir"))

  resolveImageUrl: (file) ->
    return "" if !file
    return file if utils.isUrl(file) || fs.existsSync(file)
    return path.join(config.get("siteLocalDir"), file)

  generateImageUrl: (file) ->
    return "" if !file
    return file if utils.isUrl(file)

    if @isInSiteDir(file)
      filePath = path.relative(config.get("siteLocalDir"), file)
    else
      filePath = path.join(@imagesDir(), path.basename(file))
    return path.join("/", filePath) # resolve to from root

  generateImageTag: (data) -> utils.template(config.get("imageTag"), data)
