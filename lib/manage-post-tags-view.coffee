ManageFrontMatterView = require "./manage-front-matter-view"
config = require "./config"
utils = require "./utils"

module.exports =
class ManagePostTagsView extends ManageFrontMatterView
  @labelName: "Manage Post Tags"
  @fieldName: "tags"

  fetchSiteFieldCandidates: ->
    uri = config.get("urlForTags")
    succeed = (body) =>
      tags = body.tags.map((tag) -> name: tag, count: 0)
      @rankTags(tags, @editor.getText())
      @displaySiteFieldItems(tags.map((tag) -> tag.name))
    error = (err) =>
      @error.text(err?.message || "Error fetching tags from '#{uri}'")
    utils.getJSON(uri, succeed, error)

  # rank tags based on the number of times they appeared in content
  rankTags: (tags, content) ->
    tags.forEach (tag) ->
      tagRegex = /// #{utils.regexpEscape(tag.name)} ///ig
      tag.count = content.match(tagRegex)?.length || 0
    tags.sort (t1, t2) -> t2.count - t1.count
