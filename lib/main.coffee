NewPostView = require "./new-post-view"
ManagePostTagsView = require "./manage-post-tags-view"
ManagePostCategoriesView = require "./manage-post-categories-view"

module.exports =
  newPostView: null
  managePostTagsView: null
  managePostCategoriesView: null

  configDefaults:
    siteLocalDir: "example.github.io/"
    sitePostsDir: '_posts/{year}/'
    siteUrl: "http://example.github.io/"
    urlForTags: "http://example.github.io/assets/tags.json"
    urlForCategories: "http://example.github.io/assets/tags.json"
    fileExtension: ".markdown"

  activate: (state) ->
    atom.workspaceView.command "md-writer:new-post", =>
      @newPostView = new NewPostView()
      @newPostView.display()

    atom.workspaceView.command "md-writer:manage-post-tags", =>
      @managePostTagsView = new ManagePostTagsView()
      @managePostTagsView.display()

    atom.workspaceView.command "md-writer:manage-post-categories", =>
      @managePostCategoriesView = new ManagePostCategoriesView()
      @managePostCategoriesView.display()

  deactivate: ->
    @newPostView?.detach()
    @managePostTagsView?.detach()
    @managePostCategoriesView?.detach()

  serialize: ->
