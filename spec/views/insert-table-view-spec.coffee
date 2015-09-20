InsertTableView = require "../../lib/views/insert-table-view"

describe "InsertTableView", ->
  insertTableView = null

  beforeEach -> insertTableView = new InsertTableView({})

  it "validates table rows/columns", ->
    expect(insertTableView.isValidRange(1, 1)).toBe false
    expect(insertTableView.isValidRange(2, 2)).toBe true

  describe "tableExtraPipes disabled", ->
    it "create correct (2,2) table", ->
      table = insertTableView.createTable(2, 2)
      expect(table).toEqual([
        "  |  "
        "--|--"
        "  |  "
      ].join("\n"))

    it "create correct (3,4) table", ->
      table = insertTableView.createTable(3, 4)
      expect(table).toEqual([
        "  |   |   |  "
        "--|---|---|--"
        "  |   |   |  "
        "  |   |   |  "
      ].join("\n"))

  describe "tableExtraPipes enabled", ->
    beforeEach -> atom.config.set("markdown-writer.tableExtraPipes", true)

    it "create correct (2,2) table", ->
      table = insertTableView.createTable(2, 2)
      expect(table).toEqual([
        "|   |   |"
        "|---|---|"
        "|   |   |"
      ].join("\n"))

    it "create correct (3,4) table", ->
      table = insertTableView.createTable(3, 4)
      expect(table).toEqual([
        "|   |   |   |   |"
        "|---|---|---|---|"
        "|   |   |   |   |"
        "|   |   |   |   |"
      ].join("\n"))

  describe "tableAlignment has set", ->
    it "create correct (2,2) table (center)", ->
      atom.config.set("markdown-writer.tableAlignment", "center")

      table = insertTableView.createTable(2, 2)
      expect(table).toEqual([
        "  |  "
        "::|::"
        "  |  "
      ].join("\n"))

    it "create correct (2,2) table (left)", ->
      atom.config.set("markdown-writer.tableExtraPipes", true)
      atom.config.set("markdown-writer.tableAlignment", "left")

      table = insertTableView.createTable(2, 2)
      expect(table).toEqual([
        "|   |   |"
        "|:--|:--|"
        "|   |   |"
      ].join("\n"))

    it "create correct (2,2) table (right)", ->
      atom.config.set("markdown-writer.tableExtraPipes", true)
      atom.config.set("markdown-writer.tableAlignment", "right")

      table = insertTableView.createTable(2, 2)
      expect(table).toEqual([
        "|   |   |"
        "|--:|--:|"
        "|   |   |"
      ].join("\n"))
