# generated by Neptune Namespaces v3.x.x
# file: Caffeine.Eight/index.coffee

module.exports = require './namespace'
module.exports
.includeInNamespace require './Eight'
.addModules
  CaffeineEightCompileError: require './CaffeineEightCompileError'
  NonMatch:                  require './NonMatch'                 
  Parser:                    require './Parser'                   
  PatternElement:            require './PatternElement'           
  Repl:                      require './Repl'                     
  Rule:                      require './Rule'                     
  RuleVariant:               require './RuleVariant'              
  Stats:                     require './Stats'                    
  Tools:                     require './Tools'                    
require './Extensions'
require './Nodes'