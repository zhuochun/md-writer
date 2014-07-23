NewPostView = require './new-post-view'

module.exports =
  newPostView: null
  addTagsView: null
  addCategoriesView: null
  addLinkView: null

  configDefaults:
    jekyllDir: "example.github.io/"
    tagUrl: "http://example.github.io/assets/tags.json"
    categoryUrl: "http://example.github.io/assets/tags.json"
    fileType: ".markdown"

  activate: (state) ->
    @mdWriterView = new MdWriterView(state.mdWriterViewState)

  deactivate: ->
    @mdWriterView.destroy()

  serialize: ->
    newPostViewState: @newPostView?.serialize()
