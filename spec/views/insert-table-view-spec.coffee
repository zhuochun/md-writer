InsertTableView = require "../../lib/views/insert-table-view"

describe "InsertTableView", ->
  insertTableView = null

  beforeEach ->
    insertTableView = new InsertTableView({})

  it "validates table rows/columns", ->
    expect(insertTableView.isValidRange(1, 1)).toBe false
    expect(insertTableView.isValidRange(2, 2)).toBe true

  it "create correct table", ->
    table = insertTableView.createTable(2, 2)
    expect(table).toEqual([
      "   |   "
      "---|---"
      "   |   "
    ].join("\n"))

    table = insertTableView.createTable(3, 3)
    expect(table).toEqual([
      "   |   |   "
      "---|---|---"
      "   |   |   "
      "   |   |   "
    ].join("\n"))
