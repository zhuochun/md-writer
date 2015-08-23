NewFileView = require "./new-file-view"

module.exports =
class NewDraftView extends NewFileView
  @fileType = "Draft"
  @pathConfig = "siteDraftsDir"
  @fileNameConfig = "newDraftFileName"
