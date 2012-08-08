should = require('should')
_ = require('underscore')
jua = require('../jua')

describe 'objects', ->
  it 'should allow literal assignment', ->
    expr = ->
      o = {a: 1, b: 2}
  
    jua.translate(expr).should.eql "local o\no = {a = 1, b = 2}\nreturn o"

    expr = ->
      o = {f: -> return 42}
    
    jua.translate(expr).should.eql "local o\no = {f = function()\n  return 42\nend}\nreturn o"
    
  it 'should allow field access', ->
    expr = ->
      o = {a: 1, b: 2}
      v1 = o.a
      v2 = o['a'] 
      
    jua.translate(expr).should.eql "local o\nlocal v1\nlocal v2\no = {a = 1, b = 2}\nv1 = o.a\nv2 = o['a']\nreturn v2"
    
  it 'should allow field assignment', ->
    expr = ->
      o = {}
      o.a = 1
      o['b'] = 2
      
    jua.translate(expr).should.eql "local o\no = {}\no.a = 1\no['b'] = 2\nreturn o['b']"