ManagePostCategoriesView = require "../../lib/views/manage-post-categories-view"
ManagePostTagsView = require "../../lib/views/manage-post-tags-view"

describe "ManageFrontMatterView", ->
  beforeEach ->
    waitsForPromise -> atom.workspace.open("front-matter.markdown")

  describe "ManagePostCategoriesView", ->
    [editor, categoriesView] = []

    beforeEach ->
      categoriesView = new ManagePostCategoriesView({})

    describe "when editor has malformed front matter", ->
      it "does nothing", ->
        atom.confirm = -> {} # Double, mute confirm
        editor = atom.workspace.getActiveTextEditor()
        editor.setText """
          ---
          title: Markdown Writer (Jekyll)
          ----
          ---
        """

        categoriesView.display()
        expect(categoriesView.panel.isVisible()).toBe(false)

    describe "when editor has front matter", ->
      beforeEach ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setText """
          ---
          title: Markdown Writer (Jekyll)
          date: 2015-08-12 23:19
          categories: Markdown
          tags:
            - Writer
            - Jekyll
          ---

          some random text 1
          some random text 2
        """

      it "display edit panel", ->
        categoriesView.display()
        expect(categoriesView.panel.isVisible()).toBe(true)

      it "updates editor text", ->
        categoriesView.display()
        categoriesView.saveFrontMatter()

        expect(categoriesView.panel.isVisible()).toBe(false)
        expect(editor.getText()).toBe """
          ---
          title: Markdown Writer (Jekyll)
          date: '2015-08-12 23:19'
          categories:
            - Markdown
          tags:
            - Writer
            - Jekyll
          ---

          some random text 1
          some random text 2
        """

  describe "ManagePostTagsView", ->
    [editor, tagsView] = []

    beforeEach ->
      tagsView = new ManagePostTagsView({})

    it "rank tags", ->
      fixture = "ab ab cd ab ef gh ef"
      tags = ["ab", "cd", "ef", "ij"].map (t) -> name: t

      tagsView.rankTags(tags, fixture)

      expect(tags).toEqual [
        {name: "ab", count: 3}
        {name: "ef", count: 2}
        {name: "cd", count: 1}
        {name: "ij", count: 0}
      ]

    it "rank tags with regex escaped", ->
      fixture = "c++ c.c^abc $10.0 +abc"
      tags = ["c++", "\\", "^", "$", "+abc"].map (t) -> name: t

      tagsView.rankTags(tags, fixture)

      expect(tags).toEqual [
        {name: "c++", count: 1}
        {name: "^", count: 1}
        {name: "$", count: 1}
        {name: "+abc", count: 1}
        {name: "\\", count: 0}
      ]
