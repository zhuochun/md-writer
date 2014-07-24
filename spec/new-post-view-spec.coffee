{WorkspaceView} = require "atom"
NewPostView = require "../lib/new-post-view"

describe "NewPostView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    @view = new NewPostView({})

  it "sound correct", ->
    expect(true).toBe(true)
