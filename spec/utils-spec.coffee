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

  it "check is valid html image tag", ->
    fixture = """
<img alt="alt" src="src.png" class="aligncenter" height="304" width="520">
"""
    expect(utils.isImageTag(fixture)).toBe(true)

  it "check parse valid html image tag", ->
    fixture = """
  <img alt="alt" src="src.png" class="aligncenter" height="304" width="520">
  """
    expect(utils.parseImageTag(fixture)).toEqual
      alt: "alt", src: "src.png",
      class: "aligncenter", height: "304", width: "520"

  it "check parse valid html image tag with title", ->
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

  it "check is text valid reference link with id", ->
    fixture = "[text][id with space]"
    expect(utils.isReferenceLink(fixture)).toBe(true)

  # TODO fix this to use editor
  xit "parse valid reference link text without id", ->
    content = """
Transform your plain [text][] into static websites and blogs.

[text]: http://www.jekyll.com

Markdown (or Textile), Liquid, HTML & CSS go in.
"""
    fixture = "[text][]"
    expect(utils.parseReferenceLink(fixture, content)).toEqual
      id: "text", text: "text", url: "http://www.jekyll.com", title: ""

  # TODO fix this to use editor
  xit "parse valid reference link text with id", ->
    content = """
Transform your plain [text][id] into static websites and blogs.

[id]: http://jekyll.com "Jekyll Website"

Markdown (or Textile), Liquid, HTML & CSS go in.
    """
    fixture = "[text][id]"
    expect(utils.parseReferenceLink(fixture, content)).toEqual
      id: "id", text: "text", url: "http://jekyll.com", title: "Jekyll Website"

  it "check is text invalid reference definition", ->
    fixture = "[text] http"
    expect(utils.isReferenceDefinition(fixture)).toBe(false)

  it "check is text valid reference definition", ->
    fixture = "[text text]: http"
    expect(utils.isReferenceDefinition(fixture)).toBe(true)

  it "check is text valid reference definition with title", ->
    fixture = "  [text]: http 'title not in double quote'"
    expect(utils.isReferenceDefinition(fixture)).toBe(true)

  # TODO fix this to use editor
  xit "parse valid reference definition text without id", ->
    content = """
Transform your plain [text][] into static websites and blogs.

[text]: http://www.jekyll.com

Markdown (or Textile), Liquid, HTML & CSS go in.
"""
    fixture = "[text]: http://www.jekyll.com"
    expect(utils.parseReferenceDefinition(fixture, content)).toEqual
      id: "text", text: "text", url: "http://www.jekyll.com", title: ""

  # TODO fix this to use editor
  xit "parse valid reference definition text with id", ->
    content = """
Transform your plain [text][id] into static websites and blogs.

[id]: http://jekyll.com "Jekyll Website"

Markdown (or Textile), Liquid, HTML & CSS go in.
    """
    fixture = "[id]: http://jekyll.com \"Jekyll Website\""
    expect(utils.parseReferenceDefinition(fixture, content)).toEqual
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
    fixture = "----|"
    expect(utils.isTableSeparator(fixture)).toBe(false)

    fixture = "|--|"
    expect(utils.isTableSeparator(fixture)).toBe(true)
    fixture = "--|--"
    expect(utils.isTableSeparator(fixture)).toBe(true)
    fixture = "---- |------ | ---"
    expect(utils.isTableSeparator(fixture)).toBe(true)

  it "check is table separator with extra pipes", ->
    fixture = "|-----"
    expect(utils.isTableSeparator(fixture)).toBe(false)

    fixture = "|--|--"
    expect(utils.isTableSeparator(fixture)).toBe(true)
    fixture = "|---- |------ | ---|"
    expect(utils.isTableSeparator(fixture)).toBe(true)

  it "check is table separator with format", ->
    fixture = ":--  |::---"
    expect(utils.isTableSeparator(fixture)).toBe(false)

    fixture = "|:---: |"
    expect(utils.isTableSeparator(fixture)).toBe(true)
    fixture = ":--|--:"
    expect(utils.isTableSeparator(fixture)).toBe(true)
    fixture = "|:---: |:----- | --: |"
    expect(utils.isTableSeparator(fixture)).toBe(true)

  it "parse table separator", ->
    fixture = "|----|"
    expect(utils.parseTableSeparator(fixture)).toEqual({
      separator: true
      extraPipes: true
      alignments: ["empty"]
      columns: ["----"]
      columnWidths: [4]})

    fixture = "--|--"
    expect(utils.parseTableSeparator(fixture)).toEqual({
      separator: true
      extraPipes: false
      alignments: ["empty", "empty"]
      columns: ["--", "--"]
      columnWidths: [2, 2]})

    fixture = "---- |------ | ---"
    expect(utils.parseTableSeparator(fixture)).toEqual({
      separator: true
      extraPipes: false
      alignments: ["empty", "empty", "empty"]
      columns: ["----", "------", "---"]
      columnWidths: [4, 6, 3]})

  it "parse table separator with extra pipes", ->
    fixture = "|--|--"
    expect(utils.parseTableSeparator(fixture)).toEqual({
      separator: true
      extraPipes: true
      alignments: ["empty", "empty"]
      columns: ["--", "--"]
      columnWidths: [2, 2]})

    fixture = "|---- |------ | ---|"
    expect(utils.parseTableSeparator(fixture)).toEqual({
      separator: true
      extraPipes: true
      alignments: ["empty", "empty", "empty"]
      columns: ["----", "------", "---"]
      columnWidths: [4, 6, 3]})

  it "parse table separator with format", ->
    fixture = ":--|--:"
    expect(utils.parseTableSeparator(fixture)).toEqual({
      separator: true
      extraPipes: false
      alignments: ["left", "right"]
      columns: [":--", "--:"]
      columnWidths: [3, 3]})

    fixture = "|:---: |:----- | --: |"
    expect(utils.parseTableSeparator(fixture)).toEqual({
      separator: true
      extraPipes: true
      alignments: ["center", "left", "right"]
      columns: [":---:", ":-----", "--:"]
      columnWidths: [5, 6, 3]})

  it "check table separator is a table row", ->
    fixture = ":--  |:---"
    expect(utils.isTableRow(fixture)).toBe(true)

  it "check is table row", ->
    fixture = "| empty content |"
    expect(utils.isTableRow(fixture)).toBe(true)
    fixture = "abc|feg"
    expect(utils.isTableRow(fixture)).toBe(true)
    fixture = "|   abc |efg | |"
    expect(utils.isTableRow(fixture)).toBe(true)

  it "parse table separator by table row ", ->
    fixture = "|:---: |:----- | --: |"
    expect(utils.parseTableRow(fixture)).toEqual({
      separator: true
      extraPipes: true
      alignments: ["center", "left", "right"]
      columns: [":---:", ":-----", "--:"]
      columnWidths: [5, 6, 3]})

  it "parse table row ", ->
    fixture = "| 中文 |"
    expect(utils.parseTableRow(fixture)).toEqual({
      separator: false
      extraPipes: true
      columns: ["中文"]
      columnWidths: [4]})

    fixture = "abc|feg"
    expect(utils.parseTableRow(fixture)).toEqual({
      separator: false
      extraPipes: false
      columns: ["abc", "feg"]
      columnWidths: [3, 3]})

    fixture = "|   abc |efg | |"
    expect(utils.parseTableRow(fixture)).toEqual({
      separator: false
      extraPipes: true
      columns: ["abc", "efg", ""]
      columnWidths: [3, 3, 0]})

  it "create table separator", ->
    row = utils.createTableSeparator(
      numOfColumns: 3, extraPipes: false, columnWidth: 3, alignment: "empty")
    expect(row).toEqual("---|---|---")

    row = utils.createTableSeparator(
      numOfColumns: 2, extraPipes: true, columnWidth: 3, alignment: "empty")
    expect(row).toEqual("|---|---|")

    row = utils.createTableSeparator(
      numOfColumns: 1, extraPipes: true, columnWidth: 3, alignment: "left")
    expect(row).toEqual("|:--|")

    row = utils.createTableSeparator(
      numOfColumns: 3, extraPipes: true, columnWidths: [4, 5, 5],
      alignment: "left")
    expect(row).toEqual("|:---|:----|:----|")

    row = utils.createTableSeparator(
      numOfColumns: 4, extraPipes: false, columnWidth: 5,
      alignment: "left", alignments: ["empty", "right", "center"])
    expect(row).toEqual("-----|----:|:---:|:----")

  it "create empty table row", ->
    row = utils.createTableRow([],
      numOfColumns: 3, columnWidth: 3, alignment: "empty")
    expect(row).toEqual("   |   |   ")

    row = utils.createTableRow([],
      numOfColumns: 3, extraPipes: true, columnWidths: [3, 4, 5],
      alignment: "empty")
    expect(row).toEqual("|   |    |     |")

  it "create table row", ->
    row = utils.createTableRow(["中文", "English"],
      numOfColumns: 2, extraPipes: true, columnWidths: [6, 9])
    expect(row).toEqual("| 中文 | English |")

    row = utils.createTableRow(["中文", "English"],
      numOfColumns: 2, columnWidths: [9, 11], alignments: ["right", "center"])
    expect(row).toEqual("    中文 |  English  ")

  it "create an empty table", ->
    rows = []

    options =
      numOfColumns: 3, columnWidths: [5, 3, 5],
      alignments: ["left", "center", "right"]

    rows.push(utils.createTableRow([], options))
    rows.push(utils.createTableSeparator(options))
    rows.push(utils.createTableRow([], options))

    expect(rows).toEqual([
      "     |   |     "
      ":----|:-:|----:"
      "     |   |     "
    ])

  it "create an empty table with extra pipes", ->
    rows = []

    options =
      numOfColumns: 3, extraPipes: true,
      columnWidth: 3, alignment: "empty"

    rows.push(utils.createTableRow([], options))
    rows.push(utils.createTableSeparator(options))
    rows.push(utils.createTableRow([], options))

    expect(rows).toEqual([
      "|   |   |   |"
      "|---|---|---|"
      "|   |   |   |"
    ])

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

  it "get the package path", ->
    expect(utils.getPackagePath()).toEqual(
      atom.packages.resolvePackagePath("markdown-writer"))

  it "get the package path to file", ->
    root = atom.packages.resolvePackagePath("markdown-writer")
    expect(utils.getPackagePath("CHEATSHEET.md")).toEqual(
      "#{root}/CHEATSHEET.md")
