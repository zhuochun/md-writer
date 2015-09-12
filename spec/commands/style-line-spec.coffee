LineStyleView = require "../../lib/commands/style-line"

describe "StyleLine", ->
  it "check heading 1 exists", ->
    view = new LineStyleView("h1")
    fixture = "# heading 1"
    expect(view.isStyleOn(fixture)).toBe(true)

  it "check heading 1 not exists", ->
    view = new LineStyleView("h1")
    fixture = "## heading 1"
    expect(view.isStyleOn(fixture)).toBe(false)

  it "check ul exists", ->
    view = new LineStyleView("ul")
    fixture = "* unordered list"
    expect(view.isStyleOn(fixture)).toBe(true)
    fixture = "- unordered list"
    expect(view.isStyleOn(fixture)).toBe(true)
    fixture = "0. unordered list"
    expect(view.isStyleOn(fixture)).toBe(true)

  it "check ul not exists", ->
    view = new LineStyleView("ul")
    fixture = "a unordered list"
    expect(view.isStyleOn(fixture)).toBe(false)

  it "applies heading 1 styles", ->
    atom.config.set("markdown-writer.lineStyles.h1", before: "# ", after: " #")
    view = new LineStyleView("h1")
    fixture = "## heading 1 ##"
    expect(view.addStyle(fixture)).toBe("# heading 1 #")

  it "applies heading 2 styles", ->
    view = new LineStyleView("h2")
    fixture = "# heading 2"
    expect(view.addStyle(fixture)).toBe("## heading 2")

  it "applies blockquote styles", ->
    view = new LineStyleView("blockquote")
    fixture = "blockquote"
    expect(view.addStyle(fixture)).toBe("> blockquote")

  it "applies heading 1 styles", ->
    atom.config.set("markdown-writer.lineStyles.h1", before: "# ", after: " #")
    view = new LineStyleView("h1")
    fixture = "# heading 1 #"
    expect(view.removeStyle(fixture)).toBe("heading 1")

  it "remove heading 3 styles", ->
    view = new LineStyleView("h3")
    fixture = "### heading 3"
    expect(view.removeStyle(fixture)).toBe("heading 3")

  it "remove ol styles", ->
    view = new LineStyleView("ol")
    fixture = "123. ordered list"
    expect(view.removeStyle(fixture)).toBe("ordered list")
