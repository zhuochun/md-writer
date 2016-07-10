config = require "./config"

module.exports =
  siteEngine:
    title: "Site Engine"
    type: "string"
    default: config.getDefault("siteEngine")
    enum: [config.getDefault("siteEngine"), config.engineNames()...]
  siteUrl:
    title: "Site URL"
    type: "string"
    default: config.getDefault("siteUrl")
  siteLocalDir:
    title: "Site Local Directory"
    description: "The absolute path to your site's local directory"
    type: "string"
    default: config.getDefault("siteLocalDir")
  siteDraftsDir:
    title: "Site Drafts Directory"
    description: "The relative path from your site's local directory"
    type: "string"
    default: config.getDefault("siteDraftsDir")
  sitePostsDir:
    title: "Site Posts Directory"
    description: "The relative path from your site's local directory"
    type: "string"
    default: config.getDefault("sitePostsDir")
  siteImagesDir:
    title: "Site Images Directory"
    description: "The relative path from your site's local directory"
    type: "string"
    default: config.getDefault("siteImagesDir")
  urlForTags:
    title: "URL to Tags JSON definitions"
    type: "string"
    default: config.getDefault("urlForTags")
  urlForPosts:
    title: "URL to Posts JSON definitions"
    type: "string"
    default: config.getDefault("urlForPosts")
  urlForCategories:
    title: "URL to Categories JSON definitions"
    type: "string"
    default: config.getDefault("urlForCategories")
  newDraftFileName:
    title: "New Draft File Name"
    type: "string"
    default: config.getCurrentDefault("newDraftFileName")
  newPostFileName:
    title: "New Post File Name"
    type: "string"
    default: config.getCurrentDefault("newPostFileName")
  fileExtension:
    title: "File Extension"
    type: "string"
    default: config.getCurrentDefault("fileExtension")
  relativeImagePath:
    title: "Use Relative Image Path"
    description: "Use relative image path from the open file"
    type: "boolean"
    default: config.getCurrentDefault("relativeImagePath")
  renameImageOnCopy:
    title: "Rename Image File Name"
    description: "Rename image filename when you chose to copy to image directory"
    type: "boolean"
    default: config.getCurrentDefault("renameImageOnCopy")
  tableAlignment:
    title: "Table Cell Alignment"
    type: "string"
    default: config.getDefault("tableAlignment")
    enum: ["empty", "left", "right", "center"]
  tableExtraPipes:
    title: "Table Extra Pipes"
    description: "Insert extra pipes at the start and the end of the table rows"
    type: "boolean"
    default: config.getDefault("tableExtraPipes")
