utils = require "./utils"

# Look backwards from the end of article for the first non-empty row,
# then insert the text.
#
# If the non-empty row happens to be a reference link, the text starts
# in a new line. Otherwise, the text starts in a new paragraph.
insertAtEndOfArticle = (editor, text) ->
  position = editor.getCursorBufferPosition() # keep original cursor position

  row = _findFirstNonEmptyRowBackwards(editor, editor.getLastBufferRow())
  point = [row, editor.lineTextForBufferRow(row).length]
  if _isReferenceLink(editor, row)
    editor.setTextInBufferRange [point, point], "\n#{text}"
  else
    editor.setTextInBufferRange [point, point], "\n\n#{text}"

  editor.setCursorBufferPosition(position)

_findFirstNonEmptyRowBackwards = (editor, row) ->
  row-- while row >= 0 && editor.lineTextForBufferRow(row).length == 0
  return row

# Search from the current row for the first empty row (not followed by any
# reference links) or the end of article, then insert the text.
insertAfterCurrentParagraph = (editor, text) ->
  position = editor.getCursorBufferPosition() # keep original cursor position

  row = _findFirstEmptyRow(editor, position.row + 1)
  point = [row, editor.lineTextForBufferRow(row).length]
  if _isReferenceLink(editor, row)
    editor.setTextInBufferRange [point, point], "\n#{text}"
  else if point[1] > 0
    editor.setTextInBufferRange [point, point], "\n\n#{text}"
  else
    editor.setTextInBufferRange [point, point], "\n#{text}\n"

  editor.setCursorBufferPosition(position)

_findFirstEmptyRow = (editor, row) ->
  lastRow = editor.getLastBufferRow()
  # find the first empty line
  row++ while row <= lastRow && editor.lineTextForBufferRow(row).length != 0
  return lastRow if row > lastRow
  # skip reference links
  row++ while row < lastRow && _isReferenceLink(editor, row + 1)
  return row

_isReferenceLink = (editor, row) ->
  line = editor.lineTextForBufferRow(row)
  return utils.isReferenceDefinition(line)

module.exports =
  insertAfterCurrentParagraph: insertAfterCurrentParagraph
  insertAtEndOfArticle: insertAtEndOfArticle
