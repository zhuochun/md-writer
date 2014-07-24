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

  it "test whether has front matter", ->
    fixture = "abc\n---\nhello world\n"
    expect(utils.hasFrontMatter(fixture)).toBe(false)
    fixture = "---\nkey1: val1\nkey2: val2\n---\n"
    expect(utils.hasFrontMatter(fixture)).toBe(true)

  it "get front matter as js object", ->
    fixture = "---\nkey1: val1\nkey2: val2\n---\n"
    result = utils.getFrontMatter(fixture)
    expect(result).toEqual key1: "val1", key2: "val2"

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
