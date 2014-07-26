{WorkspaceView} = require "atom"
TextStyleView = require "../lib/text-style-view"

describe "TextStyleView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

  it "check a style is added", ->
    view = new TextStyleView("bold")
    fixture = "**bold**"
    expect(view.isStyleOn(fixture)).toBe(true)

  it "check a style is not added", ->
    view = new TextStyleView("bold")
    fixture = "_not bold_"
    expect(view.isStyleOn(fixture)).toBe(false)

  it "remove a style from text", ->
    view = new TextStyleView("italic")
    fixture = "_italic text_"
    expect(view.removeStyle(fixture)).toEqual("italic text")

  it "add a style to text", ->
    view = new TextStyleView("bold")
    fixture = "bold text"
    expect(view.addStyle(fixture)).toEqual("**bold text**")
