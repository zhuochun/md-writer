NewPostView = require "./new-post-view"
ManagePostTagsView = require "./manage-post-tags-view"

module.exports =
  newPostView: null
  managePostTagsView: null

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

    atom.workspaceView.command "md-writer:manage-post-tags", =>
      @managePostTagsView = new ManagePostTagsView()
      @managePostTagsView.display()

  deactivate: ->
    @newPostView?.detach()
    @managePostTagsView?.detach()

  serialize: ->
