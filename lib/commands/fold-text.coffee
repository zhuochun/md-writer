config = require "../config"
utils = require "../utils"
heading = require "../helpers/heading"

module.exports =
class FoldText
  # action: fold-links
  constructor: (action) ->
    @action = action
    @editor = atom.workspace.getActiveTextEditor()

  trigger: (e) ->
    fn = @action.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()
    @[fn]()

  foldLinks: ->
    utils.scanLinks @editor, (range) => @editor.foldBufferRange(range)

  foldHeadings: (depth = 6) ->
    headers = @_flattenHeaders([], heading.listAll(@editor), depth)
    @_foldHeaders(headers)

  _flattenHeaders: (list, headers, depth) ->
    for header in headers
      continue if header.depth > depth

      list.push(header.range)
      @_flattenHeaders(list, header.children, depth)
    return list

  _foldHeaders: (headers) ->
    eof = @editor.getEofBufferPosition()
    while pos = headers.shift()
      endPos = if headers[0] then headers[0].start else eof
      # move up to end of previous row
      endPos.row -= 1
      endPos.column = @editor.lineTextForBufferRow(endPos.row).length
      # slight visual optimizations, skip an empty line
      if endPos.column == 0
        endPos.row -= 1
        endPos.column = @editor.lineTextForBufferRow(endPos.row).length
      # skip fold if endPos is at the same line now
      @editor.foldBufferRange([pos.end, endPos]) unless pos.end.row == endPos.row

  foldH1: -> @foldHeadings(1)
  foldH2: -> @foldHeadings(2)
  foldH3: -> @foldHeadings(3)

  focusCurrentHeading: ->
    @foldHeadings()

    pos = @editor.getCursorBufferPosition()
    for i in [0..2] # look 2 rows above, consider one empty line
      if @editor.isFoldedAtBufferRow(pos.row - i)
        @editor.unfoldBufferRow(pos.row - i)
        break
