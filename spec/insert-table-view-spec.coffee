InsertTableView = require "../lib/insert-table-view"

describe "InsertTableView", ->
  workspaceElement = null
  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    @view = new InsertTableView({})

  it "validates table rows/columns", ->
    expect(@view.isValidRange(1, 1)).toBe false
    expect(@view.isValidRange(2, 2)).toBe true

  it "create correct table row", ->
    row = @view.createTableRow 3, beg: " |", mid: " |", end: " "
    expect(row).toEqual " | | "
    row = @view.createTableRow 3, beg: "-|", mid: "-|", end: "-"
    expect(row).toEqual "-|-|-"

  it "create correct table", ->
    table = @view.createTable 2, 2
    expect(table).toEqual " |\n-|-\n |"
    table = @view.createTable 2, 3
    expect(table).toEqual " | |\n-|-|-\n | |"
