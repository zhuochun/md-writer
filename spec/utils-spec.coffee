utils = require "../lib/utils"

describe "utils", ->
  it "get posts path without token", ->
    expect(utils.dirTemplate("_posts/")).toEqual("_posts/")

  it "get posts path with tokens", ->
    date = utils.getDate()
    result = utils.dirTemplate("_posts/{year}/{month}")
    expect(result).toEqual("_posts/#{date.year}/#{date.month}")

  it "get date dashed string", ->
    date = utils.getDate()
    expect(utils.getDateStr()).toEqual("#{date.year}-#{date.month}-#{date.day}")

  it "check is text invalid inline link", ->
    fixture = "![text](url)"
    expect(utils.isInlineLink(fixture)).toBe(false)
    fixture = "[text]()"
    expect(utils.isInlineLink(fixture)).toBe(false)
    fixture = "[text][]"
    expect(utils.isInlineLink(fixture)).toBe(false)

  it "check is text valid inline link", ->
    fixture = "[text](url)"
    expect(utils.isInlineLink(fixture)).toBe(true)
    fixture = "[text](url title)"
    expect(utils.isInlineLink(fixture)).toBe(true)
    fixture = "[text](url 'title')"
    expect(utils.isInlineLink(fixture)).toBe(true)

  it "parse valid inline link text", ->
    fixture = "[text](url)"
    expect(utils.parseInlineLink(fixture)).toEqual(
      {text: "text", url: "url", title: ""})
    fixture = "[text](url title)"
    expect(utils.parseInlineLink(fixture)).toEqual(
      {text: "text", url: "url", title: "title"})
    fixture = "[text](url 'title')"
    expect(utils.parseInlineLink(fixture)).toEqual(
      {text: "text", url: "url", title: "title"})

  it "check is text invalid reference link", ->
    fixture = "![text](url)"
    expect(utils.isReferenceLink(fixture)).toBe(false)
    fixture = "[text](has)"
    expect(utils.isReferenceLink(fixture)).toBe(false)

  it "check is text valid reference link", ->
    fixture = "[text][]"
    expect(utils.isReferenceLink(fixture)).toBe(true)
    fixture = "[text][url title]"
    expect(utils.isReferenceLink(fixture)).toBe(true)

  it "check is text valid reference definition", ->
    fixture = "[text]: http"
    expect(utils.isReferenceDefinition(fixture)).toBe(true)

  it "parse valid reference link text", ->
    content = """
Transform your plain [text][]
into static websites and blogs.
[text]: http://www.jekyll.com
"""
    contentWithTitle = """
Transform your plain [text][id]
into static websites and blogs.

[id]: http://jekyll.com "Jekyll Website"

Markdown (or Textile), Liquid, HTML & CSS go in.
    """
    fixture = "[text][]"
    expect(utils.parseReferenceLink(fixture, content)).toEqual
      id: "text", text: "text", url: "http://www.jekyll.com", title: ""
    fixture = "[text][id]"
    expect(utils.parseReferenceLink(fixture, contentWithTitle)).toEqual
      id: "id", text: "text", url: "http://jekyll.com", title: "Jekyll Website"

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
    expected = """---
key1: val1
key2:
  - v1
  - v2
---

"""
    result = utils.getFrontMatterText(key1: "val1", key2: ["v1", "v2"])
    expect(result).toEqual(expected)

  it "dasherize title", ->
    fixture = "hello world!"
    expect(utils.dasherize(fixture)).toEqual("hello-world")
    fixture = "hello-world"
    expect(utils.dasherize(fixture)).toEqual("hello-world")
    fixture = " hello     World"
    expect(utils.dasherize(fixture)).toEqual("hello-world")

  it "generate templatet", ->
    fixture = "Hello <title>! -<from>"
    expect(utils.template(fixture,
      title: "world", from: "ZC")).toEqual("Hello world! -ZC")
