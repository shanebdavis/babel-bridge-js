# generated by Neptune Namespaces v2.x.x
# file: tests/namespace.coffee

Neptune = require 'neptune-namespaces'
module.exports = Neptune.Tests ||
Neptune.addNamespace 'Tests', class Tests extends Neptune.Base
  ;
require './BabelBridge/namespace'