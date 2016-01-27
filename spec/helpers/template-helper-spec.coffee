helper = require "../../lib/helpers/template-helper"

describe "templateHelper", ->
  beforeEach ->
    waitsForPromise -> atom.workspace.open("front-matter.markdown")

  describe ".getFrontMatterDate", ->
    it "get date + time to string", ->
      date = helper.getFrontMatterDate(helper.getDateTime())
      expect(date).toMatch(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}/)

  describe ".parseFrontMatterDate", ->
    it "parse date + time to hash", ->
      atom.config.set("markdown-writer.frontMatterDate", "{year}-{month}-{day} {hour}:{minute}")
      dateTime = helper.parseFrontMatterDate("2016-01-03 19:11")
      expected = year: "2016", month: "01", day: "03", hour: "19", minute: "11"
      expect(dateTime[key]).toEqual(value) for key, value in expected

  describe ".getFileSlug", ->
    it "get title slug", ->
      slug = "hello-world"
      fixture = "abc/hello-world.markdown"
      expect(helper.getFileSlug(fixture)).toEqual(slug)
      fixture = "abc/2014-02-12-hello-world.markdown"
      expect(helper.getFileSlug(fixture)).toEqual(slug)

    it "get title slug", ->
      atom.config.set("markdown-writer.newPostFileName", "{slug}-{day}-{month}-{year}{extension}")
      slug = "hello-world"
      fixture = "abc/hello-world-02-12-2014.markdown"
      expect(helper.getFileSlug(fixture)).toEqual(slug)

    it "get empty slug", ->
      expect(helper.getFileSlug(undefined)).toEqual("")
      expect(helper.getFileSlug("")).toEqual("")
