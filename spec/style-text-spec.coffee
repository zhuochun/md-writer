TextStyleView = require "../lib/style-text"

describe "StyleText", ->
  it "check a style is added", ->
    view = new TextStyleView("bold")
    fixture = "**bold**"
    expect(view.isStyleOn(fixture)).toBe(true)

  it "check any bold style is in string", ->
    view = new TextStyleView("bold")
    fixture = "hello **bold** world"
    expect(view.isStyleOn(fixture)).toBe(true)

  it "check any italic is in string", ->
    view = new TextStyleView("italic")
    fixture = "_italic_ yah _text_"
    expect(view.isStyleOn(fixture)).toBe(true)

  it "check any strike is in string", ->
    view = new TextStyleView("strikethrough")
    fixture = "**bold** one ~~strike~~ two _italic_"
    expect(view.isStyleOn(fixture)).toBe(true)

  it "check a style is not added", ->
    view = new TextStyleView("bold")
    fixture = "_not bold_"
    expect(view.isStyleOn(fixture)).toBe(false)

  it "remove a style from text", ->
    view = new TextStyleView("italic")
    fixture = "_italic text_"
    expect(view.removeStyle(fixture)).toEqual("italic text")

  it "remove bold style from text", ->
    view = new TextStyleView("bold")
    fixture = "**bold text** in a string"
    expect(view.removeStyle(fixture)).toEqual("bold text in a string")

  it "remove italic styles from text", ->
    view = new TextStyleView("italic")
    fixture = "_italic_ yah _text_ loh _more_"
    expect(view.removeStyle(fixture)).toEqual("italic yah text loh more")

  it "add a style to text", ->
    view = new TextStyleView("bold")
    fixture = "bold text"
    expect(view.addStyle(fixture)).toEqual("**bold text**")
