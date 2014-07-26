utils = require "../lib/utils"

describe "utils", ->
  it "get posts path without token", ->
    expect(utils.getPostsDir("_posts/")).toEqual("_posts/")

  it "get posts path with tokens", ->
    date = utils.getDate()
    result = utils.getPostsDir("_posts/{year}/{month}")
    expect(result).toEqual("_posts/#{date.year}/#{date.month}")

  it "get date dashed string", ->
    date = utils.getDate()
    expect(utils.getDateStr()).toEqual("#{date.year}-#{date.month}-#{date.day}")

  it "check is text invalid link", ->
    fixture = "![text](url)"
    expect(utils.isLink(fixture)).toBe(false)
    fixture = "[text]()"
    expect(utils.isLink(fixture)).toBe(false)

  it "check is text valid link", ->
    fixture = "[text](url)"
    expect(utils.isLink(fixture)).toBe(true)
    fixture = "[text](url title)"
    expect(utils.isLink(fixture)).toBe(true)
    fixture = "[text](url 'title')"
    expect(utils.isLink(fixture)).toBe(true)

  it "parse valid link text", ->
    fixture = "[text](url)"
    expect(utils.parseLink(fixture)).toEqual(
      {text: "text", url: "url", title: ""})
    fixture = "[text](url title)"
    expect(utils.parseLink(fixture)).toEqual(
      {text: "text", url: "url", title: "title"})
    fixture = "[text](url 'title')"
    expect(utils.parseLink(fixture)).toEqual(
      {text: "text", url: "url", title: "title"})

  it "test whether has front matter", ->
    fixture = "abc\n---\nhello world\n"
    expect(utils.hasFrontMatter(fixture)).toBe(false)
    fixture = "---\nkey1: val1\nkey2: val2\n---\n"
    expect(utils.hasFrontMatter(fixture)).toBe(true)

  it "get front matter as js object", ->
    fixture = "---\nkey1: val1\nkey2: val2\n---\n"
    result = utils.getFrontMatter(fixture)
    expect(result).toEqual key1: "val1", key2: "val2"

  it "get front matter as empty object", ->
    fixture = "---\n\n\n---\n"
    result = utils.getFrontMatter(fixture)
    expect(result).toEqual {}

  it "replace front matter", ->
    fixture = """---
key1: val1
key2: val2
---
this is dummy content
1,2,3"""
    expected = """---
key1: val1
key2:
  - v1
  - v2
---

this is dummy content
1,2,3"""
    result = utils.replaceFrontMatter(fixture, key1: "val1", key2: ["v1", "v2"])
    expect(result).toEqual(expected)
