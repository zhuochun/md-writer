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

  it "rank tags with regex escaped", ->
    fixture = "c++ c.c^abc $10.0 +abc"
    tags = ["c++", "\\", "^", "$", "+abc"].map (t) -> name: t

    @view.rankTags(tags, fixture)

    expect(tags).toEqual [
      { name:"c++", count:1 }
      { name:"^", count:1 }
      { name:"$", count:1 }
      { name:"+abc", count:1 }
      { name:"\\", count:0 }
    ]
