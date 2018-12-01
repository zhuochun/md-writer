anchor = require "anchor-markdown-header"

config = require "../config"
heading = require "../helpers/heading"

module.exports =
class EditToc
  constructor: (command) ->
    @command = command
    @editor = atom.workspace.getActiveTextEditor()
    @cursor = @editor.getCursorBufferPosition()

  trigger: (e) ->
    fn = @command.replace(/-[a-z]/ig, (s) -> s[1].toUpperCase())
    @[fn](e)

  insertToc: (e) ->
    toc = @_findToc()
    headers = heading.listAll(@editor)

    lines = []
    @_writeTocHead(lines, toc)
    @_writeHeaders(lines, toc.opts, "", headers)
    @_writeTocTail(lines, toc)
    text = lines.join("\n")

    if toc.found # replace
      @editor.setTextInBufferRange([toc.head.pos, toc.tail.pos], text)
    else
      @editor.insertText(text)

  # <!-- TOC --> [list] <!-- /TOC -->
  _findToc: ->
    toc = { found: false, opts: Object.assign({}, config.get("toc")) }

    # find first TOC head tag
    @editor.buffer.scan /^<!-- +TOC +(.+? +)-->$/, (match) ->
      toc.head = { pos: match.range.start, text: match.match[0] }
      # parse TOC options: depthFrom, depthTo, insertAnchor, anchorMode
      for opt in match.match[1].split(" ")
        [k, v] = opt.split(":")

        if k in ["depthFrom", "depthTo"]
          toc.opts[k] = (parseInt(v) || opts[k])
        else if k in ["insertAnchor"]
          toc.opts[k] = (v == "true")
        else if k in ["anchorMode"]
          toc.opts[k] = (v || opts[k])

    return toc unless toc.head # no TOC found

    # find first TOC tail tag
    @editor.buffer.scan /^<!-- +\/TOC +-->$/, (match) ->
      toc.tail = { pos: match.range.end, text: match.match[0] }

    toc.found = true if toc.head.pos.row < toc.tail.pos.row # check range
    return toc

  _writeTocHead: (lines, toc) ->
    if toc.found
      lines.push(toc.head.text)
    else
      lines.push("<!-- TOC -->")

    lines.push("") # empty separator

  _writeTocTail: (lines, toc) ->
    lines.push("") # empty separator

    if toc.found
      lines.push(toc.tail.text)
    else
      lines.push("<!-- /TOC -->")

  _writeHeaders: (lines, opts, indent, headers) ->
    for header in headers
      continue if header.depth > opts.depthTo # early stop

      nextIndent = indent
      if header.depth >= opts.depthFrom
        nextIndent += @editor.getTabText()

        if opts.insertAnchor
          lines.push("#{indent}- #{anchor(header.title, opts.anchorMode, header.repetition)}")
        else
          lines.push("#{indent}- #{header.title}")

      @_writeHeaders(lines, opts, nextIndent, header.children)
