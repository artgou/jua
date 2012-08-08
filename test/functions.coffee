should = require('should')
_ = require('underscore')
jua = require('../jua')

describe 'function calls', ->
  it 'should be allowed in assignments', ->
    expr = ->
      a = func()
  
    jua.translate(expr).should.eql "local a\na = func()\nreturn a"

  it 'should support arguments', ->
    expr = ->
      a = GET('abc')
      b = HGET("def:#{a}", 'blah')
      
    jua.translate(expr).should.eql "local a\nlocal b\na = GET('abc')\nb = HGET('def:' .. a, 'blah')\nreturn b"
  
describe 'function definitions', ->
  it 'should allow named functions', ->
    expr = ->
      a = -> return 123
    jua.translate(expr).should.eql "local a\na = function()\n  return 123\nend\nreturn a"
    
    expr = ->
      a = (b, c) -> return b + c
      
    jua.translate(expr).should.eql "local a\na = function(b, c)\n  return b + c\nend\nreturn a"