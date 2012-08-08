should = require('should')
_ = require('underscore')
jua = require('../jua')

describe 'type conversions', ->
  it 'should support conversion to number', ->
    expr = ->
      a = '111'
      b = Number(a)
  
    jua.translate(expr).should.eql "local a\nlocal b\na = '111'\nb = tonumber(a)\nreturn b"

  it 'should support conversion to string', ->
    expr = ->
      a = 111
      b = String(a)
      
    jua.translate(expr).should.eql "local a\nlocal b\na = 111\nb = tostring(a)\nreturn b"
    
    expr = ->
      a = 111
      b = a.toString()
      
    jua.translate(expr).should.eql "local a\nlocal b\na = 111\nb = tostring(a)\nreturn b"