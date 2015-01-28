config = require "../lib/config"

describe "config", ->
  it "get default value", ->
    expect(config.get("fileExtension")).toEqual(".markdown")

  it "get engine value", ->
    config.set("siteEngine", "jekyll")
    expect(config.getEngine("codeblock.before")).not.toBeNull()
    expect(config.getEngine("imageTag")).not.toBeDefined()

    config.set("siteEngine", "not-exists")
    expect(config.getEngine("imageTag")).not.toBeDefined()

  it "get default value from engine or user config", ->
    config.set("siteEngine", "jekyll")
    expect(config.get("codeblock.before"))
      .toEqual(config.getEngine("codeblock.before"))

    config.set("codeblock.before", "changed")
    expect(config.get("codeblock.before"))
      .toEqual("changed")

  it "get modified value", ->
    atom.config.set("markdown-writer.test", "special")
    expect(config.get("test")).toEqual("special")

  it "set key and value", ->
    config.set("test", "value")
    expect(atom.config.get("markdown-writer.test")).toEqual("value")
