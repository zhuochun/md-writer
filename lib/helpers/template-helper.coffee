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

  siteDir = utils.getSitePath(config.get("siteLocalDir"))
  fileDir = path.dirname(filePath)
  path.relative(siteDir, fileDir)

getEditor = (editor) ->
  frontMatter = new FrontMatter(editor, { silent: true })
  data = frontMatter.getContent()
  data["category"] = frontMatter.getArray(config.get("frontMatterNameCategories", allow_blank: false))[0]
  data["tag"] = frontMatter.getArray(config.get("frontMatterNameTags", allow_blank: false))[0]
  data["directory"] = getFileRelativeDir(editor.getPath())
  data["slug"] = getFileSlug(editor.getPath()) || utils.slugize(data["title"], config.get("slugSeparator"))
  data["extension"] = path.extname(editor.getPath()) || config.get("fileExtension")
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
