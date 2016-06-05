Foundation = require 'art-foundation'
Rule = require './rule'
{getLineColumn} = require './tools'

{
  BaseObject, isFunction, peek, log, isPlainObject, isPlainArray, merge, compactFlatten, objectLength, inspect,
  inspectLean
  pluralize
} = Foundation

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

  ###
  IN:
    rules: plain object mapping rule-names to definitions
    nodeClass: optional, must extend BabelBridge.Node or be a plain object
  ###
  @rule: (rules, nodeBaseClass = @nodeBaseClass)->

    for rule, definition of rules
      @addRule rule, if isPlainObject definition
        merge nodeBaseClass: nodeBaseClass, definition
      else
        pattern: definition, nodeBaseClass: nodeBaseClass

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
    @_pluralNames = {}

  pluralize: (name) ->
    @_pluralNames[name] ||= pluralize name

  ###
  OUT: on success, root Node of the parse tree, else null
  ###
  parse: (@_source, options = {})->
    @_resetParserTracking()

    ruleName = options.rule || @rootRuleName
    {rules} = @
    throw new Error "No root rule defined." unless ruleName
    startRule = rules[ruleName]
    throw new Error "Could not find rule: #{rule}" unless startRule


    if result = startRule.parse @
      if result.matchLength == @_source.length
        result
      else
        throw new Error "parse only matched #{result.matchLength} of #{@_source.length} characters"
    else
      throw new Error @getParseFailureInfo()

  getParseFailureInfo: ->
    return unless @_source

    sourceBefore = @_source.slice 0, @_failureIndex
    sourceAfter = @_source.slice @_failureIndex

    out = compactFlatten [
      """
      Parsing error at offset #{inspectLean getLineColumn @_source, @_failureIndex}

      Source:
      ...
      #{sourceBefore}<HERE>#{sourceAfter}
      ...

      """
      @getExpectingInfo()
    ]
    out.join "\n"

  getExpectingInfo: ->
    return null unless objectLength(@_expectingList) > 0

    sortedKeys = Object.keys(@_expectingList).sort()

    [
      "Could continue if one of these rules matched:"
      for k in sortedKeys
        {ruleVariant} = @_expectingList[k]
        "  #{k}"
    ]

  tryPatternElement: (patternElement, parseIntoNode, ruleVariant) ->
    if patternElement.parseInto parseIntoNode
      true
    else
      @_logParsingFailure parseIntoNode.offset,
        ruleVariant: ruleVariant
        parentNode: parseIntoNode.parent
      false

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
    result = f()
    @_matchingNegativeDepth--
    result

  ###
    expecting: {ruleVariant, parentNode}
  ###
  _logParsingFailure: (index, expecting) ->
    return if @matchingNegative

    if index >= @_failureIndex
      if index > @_failureIndex
        @_failureIndex = index
        @_expectingList = {}
      # log _logParsingFailure: index:index, expecting: expecting
      @_expectingList[expecting.ruleVariant.toString()] = expecting
