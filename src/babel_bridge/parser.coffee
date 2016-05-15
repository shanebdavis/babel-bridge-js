Foundation = require 'art-foundation'
Nodes = require './nodes'
Rule = require './rule'
{getLineColumn} = require './tools'

{
  BaseObject, isFunction, peek, log, isPlainObject, isPlainArray, merge, compactFlatten, objectLength, inspect,
  inspectLean
} = Foundation
{RootNode} = Nodes

module.exports = class Parser extends BaseObject

  @parse: (@_source, options = {})->
    (new @).parse @_source, options

  @classGetter
    rules: ->
      @getPrototypePropertyExtendedByInheritance "_rules", {}

    rootRuleName: -> @_rootRuleName

    rootRule: ->
      @getRules()[@_rootRuleName]

  @addRule: (name, options) ->
    # log addRule: name:name, options:options
    rule = @getRules()[name] ||= new Rule name, @
    @_rootRuleName ||= name

    options = pattern: options unless isPlainObject options

    rule.addVariant options

  @rule: (rules)->
    for rule, definition of rules
      @addRule rule, definition

  @getter "source parser",
    rootRuleName: -> @class.getRootRuleName()
    rootRule:     -> @class.getRootRule()
    rules:        -> @class.getRules()
    nextOffset:   -> 0

  constructor: ->
    super
    @_parser = @
    @_source = null
    @_resetParserTracking()

  # OUT: promise
  parse: (@_source, options = {})->
    @_resetParserTracking()
    log source: @_source

    ruleName = options.rule || @rootRuleName
    {rules} = @
    throw new Error "No root rule defined." unless ruleName
    startRule = rules[ruleName]
    throw new Error "Could not find rule: #{rule}" unless startRule


    if result = startRule.parse rootNode = new RootNode @
      if result.matchLength == @_source.length
        result
      else
        throw new Error "parse only matched #{result.matchLength} of #{@_source.length} characters"
    else
      throw new Error @getParseFailureInfo()

  getParseFailureInfo: ->
    return unless @_source
    out = compactFlatten [
      """
      Parsing error at offset #{inspectLean getLineColumn @_source, @_failureIndex}

      Source:
      ...
      #{@source}
      ...

      """
      @getExpectingInfo()
    ]
    out.join "\n"

  getExpectingInfo: ->
    log getExpectingInfo: @_expectingList
    return null unless objectLength(@_expectingList) > 0

    sortedKeys = Object.keys(@_expectingList).sort()

    [
      "Could continue if one of these rules matched:"
      for k in sortedKeys
        {ruleVariant} = @_expectingList[k]
        "  #{k}"
    ]

  ##################
  # PRIVATE
  ##################
  _resetParserTracking: ->
    @_matchingNegativeDepth = 0
    @_parsingDidNotMatchEntireInput = false
    @_failureIndex = 0
    @_expectingList = {}
    @_parseCache = {}

  @getter
    isMatchingNegative: -> @_matchingNegativeDepth > 0

  _matchNegative: (f) ->
    @_matchingNegativeDepth++
    f()
    @_matchingNegativeDepth--

  ###
    expecting: {ruleVariant, parentNode}
  ###
  _logParsingFailure: (index, expecting) ->
    return if @matchingNegative

    if index >= @_failureIndex
      if index > @_failureIndex
        @_failureIndex = index
        @_expectingList = {}
      log _logParsingFailure: index:index, expecting: expecting
      @_expectingList[expecting.ruleVariant.toString()] = expecting
