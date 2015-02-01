ManagePostTagsView = require "../lib/manage-post-tags-view"

describe "FrontMatterView", ->
  workspaceElement = null
  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    @view = new ManagePostTagsView({})

  it "rank tags", ->
    fixture = "ab ab cd ab ef gh ef"
    tags = ["ab", "cd", "ef", "ij"].map (t) -> name: t

    @view.rankTags(tags, fixture)

    expect(tags).toEqual [
      { name:"ab", count:3 }
      { name:"ef", count:2 }
      { name:"cd", count:1 }
      { name:"ij", count:0 }
    ]
