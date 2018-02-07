{BaseClass} = require 'art-class-system'
{defineModule} = require 'art-standard-lib'

defineModule module, class SourceLineColumnMap extends BaseClass

  constructor: (@_source)->

    count = 0
    @_lineOffsets = []
    for line in @_source.split "\n"
      @_lineOffsets.push count
      count += line.length + 1
    null

  @getter "source"

  # IN: number of characters from the start of @_source (0-based)
  #   into: {} - optionally provide an existing object to set 'line' and 'column' on to avoid creating objects
  # OUT:  line: 0, column: 0
  #   line and column are 0-based
  getLineColumn: (offset, into) ->
    los = @_lineOffsets
    i = 0
    j = los.length - 1
    while i < j
      # adjacent, set 'i' to the right one
      if i == j - 1
        if los[j] <= offset
          i = j
        else
          j = i

      # else, bisect and repeat
      else
        m = (i + j) / 2 | 0
        if los[m] > offset
          j = m
        else
          i = m

    column = offset - los[line = i]
    if into
      into.column = column
      into.line = line
      into
    else
      {column, line}
