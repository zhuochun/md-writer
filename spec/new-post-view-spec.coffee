{WorkspaceView} = require "atom"
NewPostView = require "../lib/new-post-view"

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
