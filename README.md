## CaffeineEight [![Build Status](https://travis-ci.org/caffeine-suite/caffeine-eight.svg?branch=master)](https://travis-ci.org/caffeine-suite/caffeine-eight)

CaffeineEight empowers you to write parsers quickly, elegantly and with very little code. CaffeineEight is based on [Parsing Expression Grammars](https://en.wikipedia.org/wiki/Parsing_expression_grammar) (PEG), but unlike other libraries, CaffeineEight is not a parser-generator. There is no build step. Just extend a class, add some rules and you are ready to parse. With CaffeineEight you can create and, more importantly, extend your parsers at runtime.

* Inspired by my earlier [Babel Bridge Ruby Gem](http://caffeine-eight.rubyforge.org/index.html), the JavaScript version is turning out to be even more awesome!

#### Motivating Example

```coffeescript
  CaffeineEight = require 'caffeine-eight'

  class MyParser extends CaffeineEight.Parser
    @rule foo: "/foo/ bar?"
    @rule bar: /bar/

  myParser = new MyParser
  myParser.parse "foo"
  myParser.parse "foobar"
  # yay! it worked
```

## Goals

* Define PEG parsers 100% in JavaScript
* Runtime-extensible parsers
* Reasonably fast
* No globals - each parser instance parses in its own space

## Features

* Full parsing expression grammer support with memoizing
* Full JavaScript regular expressions support for terminals
* Simple, convention-over-configuration parse-tree class structure
* Human-readable parse-tree dumps
* Detailed information about parsing failures
* Custom sub-parser hooks
  * Which enable indention-based block parsing for languages like Python, CoffeeScript, or my own CaffeineScript

## Rename History

CaffeineEight was formally called [BabelBridgeJs](https://www.npmjs.com/package/caffeine-eight)
