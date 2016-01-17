{$, View, TextEditorView} = require "atom-space-pen-views"
path = require "path"
fs = require "fs-plus"
remote = require "remote"
dialog = remote.require "dialog"

config = require "../config"
utils = require "../utils"

lastInsertImageDir = null # remember last inserted image directory

module.exports =
class InsertImageView extends View
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
    utils.setTabIndex([@imageEditor, @openImageButton, @titleEditor,
      @widthEditor, @heightEditor, @alignEditor, @copyImageCheckbox])

    @imageEditor.on "blur", => @updateImageSource(@imageEditor.getText().trim())
    @openImageButton.on "click", => @openImageDialog()

    atom.commands.add @element,
      "core:confirm": => @onConfirm()
      "core:cancel":  => @detach()

  onConfirm: ->
    imgSource = @imageEditor.getText().trim()
    return unless imgSource

    callback = => @insertImageTag(); @detach()
    if !@copyImageCheckbox.hasClass('hidden') && @copyImageCheckbox.prop("checked")
      @copyImage(@resolveImagePath(imgSource), callback)
    else
      callback()

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
    @range = utils.getTextBufferRange(@editor, "link")
    selection = @editor.getTextInRange(@range)
    return unless selection

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
      defaultPath: lastInsertImageDir || @siteLocalDir()
    return unless files && files.length > 0

    @imageEditor.setText(files[0])
    @updateImageSource(files[0])

    lastInsertImageDir = path.dirname(files[0]) unless utils.isUrl(files[0])
    @titleEditor.focus()

  updateImageSource: (file) ->
    return unless file

    @displayImagePreview(file)

    if utils.isUrl(file) || @isInSiteDir(@resolveImagePath(file))
      @copyImagePanel.addClass("hidden")
    else
      @copyImagePanel.removeClass("hidden")

  displayImagePreview: (file) ->
    return if @imageOnPreview == file

    if utils.isImageFile(file)
      @message.text("Opening Image Preview ...")
      @imagePreview.attr("src", @resolveImagePath(file))
      @imagePreview.load =>
        @message.text("")
        @setImageContext()
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

  setImageContext: ->
    { naturalWidth, naturalHeight } = @imagePreview.context
    @widthEditor.setText("" + naturalWidth)
    @heightEditor.setText("" + naturalHeight)

    position = if naturalWidth > 300 then "center" else "right"
    @alignEditor.setText(position)

  insertImageTag: ->
    imgSource = @imageEditor.getText().trim()
    img =
      rawSrc: imgSource,
      src: @generateImageSrc(imgSource)
      relativeFileSrc: @generateRelativeImageSrc(imgSource, @currentFileDir())
      relativeSiteSrc: @generateRelativeImageSrc(imgSource, @siteLocalDir())
      alt: @titleEditor.getText()
      width: @widthEditor.getText()
      height: @heightEditor.getText()
      align: @alignEditor.getText()
      slug: utils.getTitleSlug(@editor.getPath())
      site: config.get("siteUrl")

    # insert image tag when img.src exists, otherwise consider the image was removed
    if img.src
      text = utils.template(config.get("imageTag"), img)
    else
      text = img.alt

    @editor.setTextInBufferRange(@range, text)

  copyImage: (file, callback) ->
    return callback() if utils.isUrl(file) || !fs.existsSync(file)
    destFileName = path.basename(file)
    destFileName = utils.dasherize(@titleEditor.getText()) + path.extname(file) if config.get("imageAltName")

    try
      if config.get("postAssetFolder")
        destFile = path.join(path.dirname(@editor.getPath()),
                             utils.getTitleSlug(@editor.getPath()),
                             destFileName)
      else
        destFile = path.join(@siteLocalDir(), @siteImagesDir(), destFileName)

      if fs.existsSync(destFile)
        atom.confirm
          message: "File already exists!"
          detailedMessage: "Another file already exists at:\n#{destFile}"
          buttons: ['OK']
      else if config.get("imageAltName") && !utils.dasherize(@titleEditor.getText())
        atom.confirm
          message: "Empty file name!"
          detailedMessage: "Check your <alt> field and ensure it includes at least one alphanumeric letter."
          buttons: ['Fuck']
      else
        fs.copy file, destFile, =>
          @imageEditor.setText(destFile)
          callback()
    catch error
      atom.confirm
        message: "[Markdown Writer] Error!"
        detailedMessage: "Copy Image:\n#{error.message}"
        buttons: ['OK']

  # get user's site local directory
  siteLocalDir: -> config.get("siteLocalDir") || utils.getProjectPath()

  # get user's site images directory
  siteImagesDir: -> utils.dirTemplate(config.get("siteImagesDir"))

  # get current open file directory
  currentFileDir: -> path.dirname(@editor.getPath() || "")

  # check the file is in the site directory
  isInSiteDir: (file) -> file && file.startsWith(@siteLocalDir())

  # try to resolve file to a valid src that could be displayed
  resolveImagePath: (file) ->
    return "" unless file
    return file if utils.isUrl(file) || fs.existsSync(file)
    absolutePath = path.join(@siteLocalDir(), file)
    return absolutePath if fs.existsSync(absolutePath)
    return file # fallback to not resolve

  # generate a src that is used in markdown file based on user configuration or file location
  generateImageSrc: (file) ->
    return "" unless file
    return file if utils.isUrl(file)
    return path.basename(file) if config.get("postAssetFolder") &&
                                  !@copyImageCheckbox.hasClass('hidden') &&
                                  @copyImageCheckbox.prop("checked")
    return path.relative(@currentFileDir(), file) if config.get('relativeImagePath')
    return path.relative(@siteLocalDir(), file) if @isInSiteDir(file)
    return path.join("/", @siteImagesDir(), path.basename(file))

  # generate a relative src from the base path or from user's home directory
  generateRelativeImageSrc: (file, basePath) ->
    return "" unless file
    return file if utils.isUrl(file)
    return path.relative(basePath || "~", file)
