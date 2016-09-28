Foundation = require 'art-foundation'
{peek, log, push, compactFlatten, BaseObject, inspectedObjectLiteral, merge} = Foundation
Nodes = require './namespace'

module.exports = class Node extends BaseObject
  constructor: (@_parent, options) ->
    super
    {@_parser} = @_parent
    {@offset, @matchLength, @ruleVariant} = options if options
    @_offset ?= @_parent.getNextOffset()
    @_matchLength ||= 0
    @_lastMatch = null
    @_matches = null

  @setter "matches offset matchLength ruleVariant"
  @getter
    parseTreePath: -> compactFlatten [@parent?.parseTreePath, @class.getName()]
    matches: -> @_matches ||= []

  toString: -> @text

  @getter "parent parser offset matchLength ruleVariant"
  @getter
    inspectedObjects: ->
      m = @_matches || []
      if m.length > 0
        ret = {}
        ret[@class.getName()] = if m.length == 1
          m[0].inspectedObjects
        else
          match.inspectedObjects for match in @_matches
        ret
      else
        @text #, offset: @offset, length: @matchLength

    text: -> if @matchLength == 0 then "" else @source.slice @_offset, @_offset + @matchLength
    source: -> @_parser.source
    nextOffset: -> @offset + @matchLength
    plainObjects: ->
      ret = [{inspect:=>@class.getName()}]
      if @_matches?.length > 0
        ret = ret.concat (match.getPlainObjects() for match in @matches)
      else
        ret = @text #, offset: @offset, length: @matchLength
      ret

  subParse: (subSource, options) ->
    @_parser.subParse subSource, merge options #, parentNode: @

  ###
  IN: match - instanceof Node
  OUT: true if match was added
  ###
  addMatch: (label, match) ->
    return false unless match

    match._parent = @

    @_matches = push @_matches, @_lastMatch = match
    if label && match.class != Nodes.EmptyOptionalNode
      @_bindToLabelLists label, match
      @_bindToSingleLabels label, match

    @_matchLength = match.nextOffset - @offset
    true

  #################
  # PRIVATE
  #################

  # add to appropriate list in @matches
  _bindToLabelLists: (label, match) ->
    pluralLabel = @parser.pluralize label
    {matches} = @
    @[pluralLabel] = push @[pluralLabel], match unless @__proto__[pluralLabel]

  # keep most recent match directly as node property
  # IFF the prototype doesn't already have a property of that name
  _bindToSingleLabels: (label, match) ->
    @[label] = match unless @__proto__[label]
