{$} = require "atom-space-pen-views"
path = require "path"

config = require "../config"
utils = require "../utils"
FrontMatter = require "./front-matter"

# All template should be created from here
create = (key, data...) ->
  data = $.extend({}, getTemplateVariables(), data...)
  utils.template(config.get(key), data)

getTemplateVariables = ->
  $.extend({ site: config.get("siteUrl") }, config.get("templateVariables") || {})

getDateTime = (date = new Date()) ->
  utils.getDate(date)

getFrontMatterDate = (dateTime) ->
  utils.template(config.get("frontMatterDate"), dateTime)

parseFrontMatterDate = (str) ->
  fn = utils.untemplate(config.get("frontMatterDate"))
  dateHash = fn(str)
  utils.parseDate(dateHash) if dateHash

getFrontMatter = (frontMatter) ->
  layout: frontMatter.getLayout()
  published: frontMatter.getPublished()
  title: frontMatter.getTitle()
  slug: frontMatter.getSlug()
  date: frontMatter.getDate()
  extension: frontMatter.getExtension()

getFileSlug = (filePath) ->
  return "" unless filePath

  filename = path.basename(filePath)
  templates = [config.get("newPostFileName"), config.get("newDraftFileName"), "{slug}{extension}"]
  for template in templates
    hash = utils.untemplate(template)(filename)
    if hash && (hash["slug"] || hash["title"]) # title is the legacy slug alias in filename
      return hash["slug"] || hash["title"]

getFileRelativeDir = (filePath) ->
  return "" unless filePath

  siteDir = utils.getSitePath(config.get("siteLocalDir"), filePath)
  fileDir = path.dirname(filePath)
  path.relative(siteDir, fileDir)

getEditor = (editor) ->
  filePath = editor.getPath() || "" # getPath is undefined when editor opens in an empty window/workspace
  frontMatter = new FrontMatter(editor, { silent: true })

  data = frontMatter.getContent()
  data["category"] = data["category"] || frontMatter.getArray(config.get("frontMatterNameCategories", allow_blank: false))[0]
  data["tag"] = data["tag"] || frontMatter.getArray(config.get("frontMatterNameTags", allow_blank: false))[0]
  data["slug"] = data["slug"] || utils.slugize(getFileSlug(filePath) || data["title"], config.get("slugSeparator"))
  data["directory"] = getFileRelativeDir(filePath)
  data["filename"] = getFileSlug(filePath) || ""
  data["extension"] = path.extname(filePath) || config.get("fileExtension")
  data

module.exports =
  create: create
  getTemplateVariables: getTemplateVariables
  getDateTime: getDateTime
  getFrontMatter: getFrontMatter
  getFrontMatterDate: getFrontMatterDate
  parseFrontMatterDate: parseFrontMatterDate
  getEditor: getEditor
  getFileSlug: getFileSlug
