listAll = (editor) ->
  repetition = {} # num of times of same title is repeated
  headers = []

  curHeader = undefined
  editor.buffer.scan /^(\#{1,6}) +(.+?) *$/g, (match) ->
    descriptors = editor.scopeDescriptorForBufferPosition(match.range.start).getScopesArray()
    # exclude headings in comments/code blocks
    return unless descriptors.find((descriptor) -> descriptor.indexOf("heading") >= 0)

    title = match.match[2]
    # count number of duplicates/repetitions
    if repetition[title]?
      repetition[title] += 1
    else
      repetition[title] = 0

    header = {
      range: match.range,
      text: match.match[0],
      depth: match.match[1].length,
      title: title,
      repetition: repetition[title],
      children: []
    }

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

module.exports =
  listAll: listAll
