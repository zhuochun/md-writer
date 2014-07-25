NewPostView = require "./new-post-view"
AddLinkView = require "./add-link-view"
ManagePostTagsView = require "./manage-post-tags-view"
ManagePostCategoriesView = require "./manage-post-categories-view"

module.exports =
  newPostView: null
  addLinkView: null
  managePostTagsView: null
  managePostCategoriesView: null

  configDefaults:
    siteLocalDir: "example.github.io/"
    siteLinkPath: "example.github.io/_link.cson"
    sitePostsDir: "_posts/{year}/"
    siteUrl: "http://example.github.io/"
    urlForTags: "http://example.github.io/assets/tags.json"
    urlForPosts: "http://example.github.io/assets/posts.json"
    urlForCategories: "http://example.github.io/assets/categories.json"
    fileExtension: ".markdown"

  activate: (state) ->
    atom.workspaceView.command "md-writer:new-post", =>
      @newPostView = new NewPostView()
      @newPostView.display()

    atom.workspaceView.command "md-writer:add-link", =>
      @addLinkView = new AddLinkView()
      @addLinkView.display()

    atom.workspaceView.command "md-writer:manage-post-tags", =>
      @managePostTagsView = new ManagePostTagsView()
      @managePostTagsView.display()

    atom.workspaceView.command "md-writer:manage-post-categories", =>
      @managePostCategoriesView = new ManagePostCategoriesView()
      @managePostCategoriesView.display()

  deactivate: ->
    @newPostView?.detach()
    @addLinkView?.detach()
    @managePostTagsView?.detach()
    @managePostCategoriesView?.detach()

  serialize: ->
