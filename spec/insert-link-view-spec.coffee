{WorkspaceView} = require "atom"
InsertLinkView = require "../lib/insert-link-view"

describe "InsertLinkView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    @view = new InsertLinkView({})

  it "get saved link path", ->
    expect(@view.getSavedLinksPath()).toMatch(atom.getConfigDirPath())

  it "get configured saved link path", ->
    path = "path/to/link.cson"
    atom.config.set("markdown-writer.siteLinkPath", path)
    expect(@view.getSavedLinksPath()).toEqual(path)
