clipboard = require 'clipboard'

InsertImageFileView = require "../views/insert-image-file-view"
InsertImageClipboardView = require "../views/insert-image-clipboard-view"

module.exports =
class InsertImage
  trigger: (e) ->
    if clipboard.readImage().isEmpty()
      view = new InsertImageFileView()
      view.display()
    else
      view = new InsertImageClipboardView()
      view.display()
