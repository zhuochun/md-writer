anchor = require "anchor-markdown-header"

config = require "../config"

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
    headers = @_listHeaders(toc.opts)

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
    @editor.buffer.scan /^<!-- +TOC +(.+? +)-->$/, (match) =>
      toc.head = {
        pos: match.range.start,
        text: match.match[0],
      }
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
    @editor.buffer.scan /^<!-- +\/TOC +-->$/, (match) =>
      toc.tail = {
        pos: match.range.end,
        text: match.match[0]
      }

    toc.found = true if toc.head.pos.row < toc.tail.pos.row # check range
    return toc

  _listHeaders: (opts) ->
    duplicate = {} # num of duplicated header titles

    headers = []
    curHeader = undefined

    @editor.buffer.scan /^(\#{1,6}) +(.+?) *$/g, (match) =>
      descriptors = @editor.scopeDescriptorForBufferPosition(match.range.start).getScopesArray()
      # exclude headings in comments/code blocks
      return unless descriptors.find((descriptor) -> descriptor.indexOf("heading") >= 0)

      header = {
        text: match.match[0],
        title: match.match[2],
        depth: match.match[1].length,
        children: []
      }

      # generate anchor text
      if duplicate[header.title] == null
        duplicate[header.title] = 0
      else
        duplicate[header.title] += 1
      # duplicate number is used to differentiate same title
      header.anchor = anchor(header.title, opts.anchorMode, duplicate[header.title])

      # find position in header tree
      parent = curHeader
      parent = parent.parent while parent && parent.depth >= header.depth
      # attach to parent
      if parent
        header.parent = parent
        parent.children.push(header)
      else # top-level header
        headers.push(header)

      curHeader = header

    return headers

  _writeTocHead: (lines, toc) ->
    if toc.found
      lines.push(toc.head.text)
    else
      lines.push("<!-- TOC -->")

  _writeTocTail: (lines, toc) ->
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
          lines.push("#{indent}- #{header.anchor}")
        else
          lines.push("#{indent}- #{header.title}")

      @_writeHeaders(lines, opts, nextIndent, header.children)
