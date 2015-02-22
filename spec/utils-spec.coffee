utils = require "../lib/utils"

describe "utils", ->
  it "get date dashed string", ->
    date = utils.getDate()
    expect(utils.getDateStr()).toEqual("#{date.year}-#{date.month}-#{date.day}")

  it "check is valid image", ->
    fixture = "![text](url)"
    expect(utils.isImage(fixture)).toBe(true)
    fixture = "[text](url)"
    expect(utils.isImage(fixture)).toBe(false)

  it "parse valid image", ->
    fixture = "![text](url)"
    expect(utils.parseImage(fixture)).toEqual
      alt: "text", src: "url", title: ""

  it "check is valid raw image", ->
    fixture = """
<img alt="alt" src="src.png" class="aligncenter" height="304" width="520">
"""
    expect(utils.isImageTag(fixture)).toBe(true)

  it "check parse valid raw image", ->
    fixture = """
  <img alt="alt" src="src.png" class="aligncenter" height="304" width="520">
  """
    expect(utils.parseImageTag(fixture)).toEqual
      alt: "alt", src: "src.png",
      class: "aligncenter", height: "304", width: "520"

  it "check parse valid raw image 2", ->
    fixture = """
  <img title="" src="src.png" class="aligncenter" height="304" width="520" />
  """
    expect(utils.parseImageTag(fixture)).toEqual
      title: "", src: "src.png",
      class: "aligncenter", height: "304", width: "520"

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

  it "test not has front matter", ->
    fixture = "title\n---\nhello world\n"
    expect(utils.hasFrontMatter(fixture)).toBe(false)

  it "test has front matter", ->
    fixture = "---\nkey1: val1\nkey2: val2\n---\n" # jeykll
    expect(utils.hasFrontMatter(fixture)).toBe(true)
    fixture = "key1: val1\nkey2: val2\n---\n" # hexo
    expect(utils.hasFrontMatter(fixture)).toBe(true)

  it "get front matter as js object (jekyll)", ->
    fixture = "---\nkey1: val1\nkey2: val2\n---\n"
    result = utils.getFrontMatter(fixture)
    expect(result).toEqual key1: "val1", key2: "val2"

  it "get front matter as js object (hexo)", ->
    fixture = "key1: val1\nkey2: val2\n---\n"
    result = utils.getFrontMatter(fixture)
    expect(result).toEqual key1: "val1", key2: "val2"

  it "get front matter as empty object", ->
    fixture = "---\n\n\n---\n"
    result = utils.getFrontMatter(fixture)
    expect(result).toEqual {}
    fixture = "\n\n\n---\n"
    result = utils.getFrontMatter(fixture)
    expect(result).toEqual {}
    fixture = "this is content\nwith no front matters\n"
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

  it "check is url", ->
    fixture = "https://github.com/zhuochun/md-writer"
    expect(utils.isUrl(fixture)).toBe(true)
    fixture = "/Users/zhuochun/md-writer"
    expect(utils.isUrl(fixture)).toBe(false)

  it "check is table separator", ->
    fixture = "--|------|---"
    expect(utils.isTableSeparator(fixture)).toBe(true)
    fixture = "---- |------ | ---"
    expect(utils.isTableSeparator(fixture)).toBe(true)
    fixture = "------ | --------|--------"
    expect(utils.isTableSeparator(fixture)).toBe(true)

  it "replace front matter (no leading fence)", ->
    expected = """
key1: val1
key2:
  - v1
  - v2
---

"""
    result = utils.getFrontMatterText(
      {key1: "val1", key2: ["v1", "v2"]}, true)
    expect(result).toEqual(expected)

  it "dasherize title", ->
    fixture = "hello world!"
    expect(utils.dasherize(fixture)).toEqual("hello-world")
    fixture = "hello-world"
    expect(utils.dasherize(fixture)).toEqual("hello-world")
    fixture = " hello     World"
    expect(utils.dasherize(fixture)).toEqual("hello-world")

  it "get title slug", ->
    slug = "hello-world"
    fixture = "abc/hello-world.markdown"
    expect(utils.getTitleSlug(slug)).toEqual(slug)
    fixture = "abc/2014-02-12-hello-world.markdown"
    expect(utils.getTitleSlug(fixture)).toEqual(slug)
    fixture = "abc/02-12-2014-hello-world.markdown"
    expect(utils.getTitleSlug(fixture)).toEqual(slug)

  it "generate posts directory without token", ->
    expect(utils.dirTemplate("_posts/")).toEqual("_posts/")

  it "generate posts directory with tokens", ->
    date = utils.getDate()
    result = utils.dirTemplate("_posts/{year}/{month}")
    expect(result).toEqual("_posts/#{date.year}/#{date.month}")

  it "generate template", ->
    fixture = "<a href=''>hello <title>! <from></a>"
    expect(utils.template(fixture, title: "world", from: "markdown-writer"))
      .toEqual("<a href=''>hello world! markdown-writer</a>")

  it "generate template with data missing", ->
    fixture = "<a href='<url>' title='<title>'><img></a>"
    expect(utils.template(fixture, url: "//", title: ''))
      .toEqual("<a href='//' title=''><img></a>")
