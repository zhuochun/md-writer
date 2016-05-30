config = require "../config"
utils = require "../utils"

ManageFrontMatterView = require "./manage-front-matter-view"

module.exports =
class ManagePostCategoriesView extends ManageFrontMatterView
  @labelName: "Manage Post Categories"
  @fieldName: config.get("frontMatterNameCategories", allow_blank: false)

  fetchSiteFieldCandidates: ->
    uri = config.get("urlForCategories")
    succeed = (body) =>
      @displaySiteFieldItems(body.categories || [])
    error = (err) =>
      @error.text(err?.message || "Error fetching categories from '#{uri}'")
    utils.getJSON(uri, succeed, error)
