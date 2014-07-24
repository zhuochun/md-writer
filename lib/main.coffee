NewPostView = require "./new-post-view"

module.exports =
  newPostView: null
  addTagsView: null
  addCategoriesView: null
  addLinkView: null

  configDefaults:
    siteLocalDir: "example.github.io/"
    sitePostsDir: '_posts/{year}/'
    siteUrl: "http://example.github.io/"
    tagUrl: "http://example.github.io/assets/tags.json"
    categoryUrl: "http://example.github.io/assets/tags.json"
    fileExtension: ".markdown"

  activate: (state) ->
    atom.workspaceView.command "md-writer:new-post", =>
      @newPostView = new NewPostView()
      @newPostView.display()

  deactivate: ->
    @newPostView?.detach()

  serialize: ->
