InsertLinkView = require "../lib/insert-link-view"

describe "InsertLinkView", ->
  workspaceElement = null
  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    @view = new InsertLinkView({})

  it "get saved link path", ->
    expect(@view.getSavedLinksPath()).toMatch(atom.getConfigDirPath())

  it "get configured saved link path", ->
    path = "path/to/link.cson"
    atom.config.set("markdown-writer.siteLinkPath", path)
    expect(@view.getSavedLinksPath()).toEqual(path)
