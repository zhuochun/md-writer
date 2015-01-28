NewPostView = require "../lib/new-post-view"

describe "NewPostView", ->
  workspaceElement = null
  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    @view = new NewPostView({})

  it "get filename in hexo format", ->
    atom.config.set("markdown-writer.newPostFileName", "{title}{extension}")
    atom.config.set("markdown-writer.fileExtension", ".markdown")
    @view.titleEditor.setText("Hexo format")
    @view.dateEditor.setText("2014-11-19")
    expect(@view.getFileName()).toEqual "hexo-format.markdown"

  it "generate front matter", ->
    frontMatter =
      layout: "test"
      title: "the actual title"
      date: "2014-11-19"

    expect(@view.generateFrontMatter(frontMatter)).toEqual """
---
layout: test
title: "the actual title"
date: "2014-11-19"
---
"""

  it "generate front matter from setting", ->
    frontMatter =
      layout: "test"
      title: "the actual title"
      date: "2014-11-19"
    atom.config.set("markdown-writer.frontMatter", "title: <title>")
    expect(@view.generateFrontMatter(frontMatter))
      .toEqual("title: the actual title")
