{WorkspaceView} = require "atom"
NewPostView = require "../lib/new-post-view"
utils = require "../lib/utils"

describe "NewPostView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    @view = new NewPostView({})

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

  it "return file name with Date", ->
    @view.dateEditor.setText(utils.getDateStr())
    expect(@view.getFileName())
      .toMatch(/^\d{4}-\d{1,2}-\d{1,2}/)

  it "return file name without Date", ->
    atom.config.set("markdown-writer.checkedForHexo", true)
    @view.dateEditor.setText(utils.getDateStr())
    expect(@view.getFileName())
      .not.toMatch(/^\d{4}-\d{1,2}-\d{1,2}/)
