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
  category: frontMatter.getCategory()
  extension: frontMatter.getExtension()

parseFileSlug = (filePath) ->
  return "" unless filePath

  filename = path.basename(filePath)
  templates = [config.get("newPostFileName"), config.get("newDraftFileName"), "{slug}{extension}"]

  for template in templates
    hash = utils.untemplate(template)(filename)
    if hash && (hash["slug"] || hash["title"])
      return hash["slug"] || hash["title"]

getEditor = (editor) ->
  data = new FrontMatter(editor, { silent: true }).getContent()
  data["slug"] = parseFileSlug(editor.getPath()) || utils.slugize(data['title'], config.get('slugSeparator'))
  data["extension"] = path.extname(@draftPath) || config.get("fileExtension")
  data

module.exports =
  create: create
  getTemplateVariables: getTemplateVariables
  getDateTime: getDateTime
  getFrontMatter: getFrontMatter
  getFrontMatterDate: getFrontMatterDate
  parseFrontMatterDate: parseFrontMatterDate
  getEditor: getEditor
  parseFileSlug: parseFileSlug
