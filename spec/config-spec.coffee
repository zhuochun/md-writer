{WorkspaceView} = require "atom"
config = require "../lib/config"

describe "config", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

  it "get defaults value", ->
    expect(config.get("fileExtension")).toEqual(".markdown")

  it "get modified value", ->
    atom.config.set("markdown-writer.test", "special")
    expect(config.get("test")).toEqual("special")

  it "set key and value", ->
    config.set("test", "value")
    expect(atom.config.get("markdown-writer.test")).toEqual("value")

  it "get engines", ->
    expect(config.engineNames()).toEqual(["jekyll", "hexo"])

  it "set engine defaults", ->
    config.setEngine("jekyll")
    expect(atom.config.get("markdown-writer.codeblock.before"))
      .toEqual("{% highlight %}\n")
