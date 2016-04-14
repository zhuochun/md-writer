path = require "path"
config = require "../lib/config"

describe "config", ->
  describe ".set", ->
    it "get user modified value", ->
      atom.config.set("markdown-writer.test", "special")
      expect(config.get("test")).toEqual("special")

    it "set key and value", ->
      config.set("test", "value")
      expect(atom.config.get("markdown-writer.test")).toEqual("value")

  describe ".get", ->
    it "get value from default", ->
      expect(config.get("fileExtension")).toEqual(".markdown")

    it "get value from engine config", ->
      config.set("siteEngine", "jekyll")
      expect(config.get("codeblock.before"))
        .toEqual(config.getEngine("codeblock.before"))

    it "get value from default if engine is invalid", ->
      config.set("siteEngine", "not-exists")
      expect(config.get("codeblock.before"))
        .toEqual(config.getDefault("codeblock.before"))

    it "get value from user config", ->
      config.set("codeblock.before", "changed")
      expect(config.get("codeblock.before")).toEqual("changed")

    it "get value from user config even if the config is empty string", ->
      config.set("codeblock.before", "")
      expect(config.get("codeblock.before")).toEqual("")

    it "get value from default config if user config is empty string", ->
      config.set("codeblock.before", undefined)
      expect(config.get("codeblock.before"))
        .toEqual(config.getDefault("codeblock.before"))

      config.set("codeblock.before", null)
      expect(config.get("codeblock.before"))
        .toEqual(config.getDefault("codeblock.before"))

  describe ".getEngine", ->
    it "get value from engine config", ->
      config.set("siteEngine", "jekyll")
      expect(config.getEngine("codeblock.before")).not.toBeNull()
      expect(config.getEngine("imageTag")).not.toBeDefined()

    it "get value from invalid engine config", ->
      config.set("siteEngine", "not-exists")
      expect(config.getEngine("imageTag")).not.toBeDefined()

  describe ".getProject", ->
    originalGetProjectConfigFile = config.getProjectConfigFile
    afterEach -> config.getProjectConfigFile = originalGetProjectConfigFile

    it "get value when file found", ->
      config.getProjectConfigFile = -> path.resolve(__dirname, "fixtures", "dummy.cson")
      expect(config.getProject("imageTag")).toEqual("imageTag")

    it "get empty when file is empty", ->
      config.getProjectConfigFile = -> path.resolve(__dirname, "fixtures", "empty.cson")
      expect(config.getProject("imageTag")).not.toBeDefined()

    it "get empty when file is not found", ->
      config.getProjectConfigFile = -> path.resolve(__dirname, "fixtures", "notfound.cson")
      expect(config.getProject("imageTag")).not.toBeDefined()
