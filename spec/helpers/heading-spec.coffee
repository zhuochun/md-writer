heading = require "../../lib/helpers/heading"

describe "heading", ->
  [editor] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("toc.markdown")
    waitsForPromise -> atom.packages.activatePackage("language-gfm")
    runs -> editor = atom.workspace.getActiveTextEditor()

  describe "listAll", ->
    it "list no headings", ->
      editor.setText """
      this is a sentence

      ```
      # this is not a header
      ```

      this is a sentence
      """
      editor.setCursorBufferPosition([5, 3])

      h = heading.listAll(editor)
      expect(h.length).toBe(0)

    it "list all headings", ->
      editor.setText """
      # Markdown-Writer for Atom

      ## Features

      ### Blogging

      ### General

      ## Installation

      ### General

      ## Setup

      ## Contributing

      ## Project
      """
      editor.setCursorBufferPosition([2, 0])

      h = heading.listAll(editor)
      # heading 1
      expect(h.length).toBe(1)
      expect(h[0].title).toBe("Markdown-Writer for Atom")
      # heading 2
      h2 = h[0].children
      expect(h2.length).toBe(5)
      expect(h2[4].title).toBe("Project")
      # heading 3
      h3 = h2[1].children
      expect(h3.length).toBe(1)
      expect(h3[0].title).toBe("General")
      expect(h3[0].repetition).toBe(1)
