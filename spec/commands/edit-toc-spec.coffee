EditTOC = require "../../lib/commands/edit-toc"

describe "EditTOC", ->
  [editor, editTOC] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("toc.markdown")
    waitsForPromise -> atom.packages.activatePackage("language-gfm")
    runs -> editor = atom.workspace.getActiveTextEditor()

  describe "No headers", ->
    beforeEach -> editTOC = new EditTOC("insert-toc")

    it "insert empty TOC", ->
      editor.setText """


      this is a sentence
      """
      editor.setCursorBufferPosition([0, 0])

      editTOC.trigger()
      expect(editor.getText()).toBe """
      <!-- TOC -->


      <!-- /TOC -->

      this is a sentence
      """

  describe "With headers", ->
    beforeEach -> editTOC = new EditTOC("insert-toc")

    it "insert new TOC", ->
      editor.setText """
      # Markdown-Writer for Atom



      ## Features

      ### Blogging

      ### General

      ## Installation

      ## Setup

      ## Contributing

      ## Project
      """
      editor.setCursorBufferPosition([2, 0])

      editTOC.trigger()
      expect(editor.getText()).toBe """
      # Markdown-Writer for Atom

      <!-- TOC -->

      - [Markdown-Writer for Atom](#markdown-writer-for-atom)
        - [Features](#features)
          - [Blogging](#blogging)
          - [General](#general)
        - [Installation](#installation)
        - [Setup](#setup)
        - [Contributing](#contributing)
        - [Project](#project)

      <!-- /TOC -->

      ## Features

      ### Blogging

      ### General

      ## Installation

      ## Setup

      ## Contributing

      ## Project
      """

    it "update TOC based on options", ->
      editor.setText """
      # Markdown-Writer for Atom

      <!-- TOC depthFrom:2 -->

      - [Markdown-Writer for Atom](#markdown-writer-for-atom)
        - [Features](#features)
          - [Blogging](#blogging)
          - [General](#general)
        - [Installation](#installation)
        - [Setup](#setup)
        - [Contributing](#contributing)
        - [Project](#project)

      <!-- /TOC -->

      ## Features

      ### Blogging

      ### General

      ## Installation

      ## Setup

      ## Contributing

      ## Project
      """
      editor.setCursorBufferPosition([8, 0])

      editTOC.trigger()
      expect(editor.getText()).toBe """
      # Markdown-Writer for Atom

      <!-- TOC depthFrom:2 -->

      - [Features](#features)
        - [Blogging](#blogging)
        - [General](#general)
      - [Installation](#installation)
      - [Setup](#setup)
      - [Contributing](#contributing)
      - [Project](#project)

      <!-- /TOC -->

      ## Features

      ### Blogging

      ### General

      ## Installation

      ## Setup

      ## Contributing

      ## Project
      """
