NewFileView = require "./new-file-view"

module.exports =
class NewPostView extends NewFileView
  @fileType = "Post"
  @pathConfig = "sitePostsDir"
  @fileNameConfig = "newPostFileName"
