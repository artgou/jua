should = require('should')
_ = require('underscore')
jua = require('../jua')

describe 'variable declarations', ->
  it 'should support numerical literals', ->
    expr = ->
      a = 1
      b = 2
  
    jua.translate(expr).should.eql "local a\nlocal b\na = 1\nb = 2\nreturn b"

  it 'should support numerical expressions', ->
    expr = ->
      a = 1
      b = 2
      c = a + b + 3
      
    jua.translate(expr).should.eql "local a\nlocal b\nlocal c\na = 1\nb = 2\nc = a + b + 3\nreturn c"
    
    expr = ->
      a = 3 * 5
      
    jua.translate(expr).should.eql "local a\na = 3 * 5\nreturn a"
    
    expr = ->
      a = 7 - 6
      
    jua.translate(expr).should.eql "local a\na = 7 - 6\nreturn a"
    
  it 'should support string literals', ->
    expr = ->
      a = 'abc'
      b = 'def'
      
    jua.translate(expr).should.eql "local a\nlocal b\na = 'abc'\nb = 'def'\nreturn b"
  
  it 'should support string escape sequences', ->
    expr = ->
      a = '\'abc\''
      
    jua.translate(expr).should.eql "local a\na = '\\'abc\\''\nreturn a"
    
    expr = ->
      a = 'a\nb\\c'
    
    jua.translate(expr).should.eql "local a\na = 'a\\nb\\\\c'\nreturn a"
    
  it 'should support string concatenation', ->
    expr = ->
      a = 'abc'
      a = 'abc' + 'def'
      a = a + 'ghi'
      
    jua.translate(expr).should.eql "local a\na = 'abc'\na = 'abc' .. 'def'\na = a .. 'ghi'\nreturn a"
    
    expr = ->
      a = "abc"
      b = "def"
      c = "#{a}:#{b}"
      
    jua.translate(expr).should.eql "local a\nlocal b\nlocal c\na = 'abc'\nb = 'def'\nc = a .. ':' .. b\nreturn c"

  it 'should support null values', ->
    expr = ->
      a = null

    jua.translate(expr).should.eql "local a\na = nil\nreturn a"
