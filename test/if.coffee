should = require('should')
_ = require('underscore')
jua = require('../jua')

describe 'if structure', ->
  it 'should support boolean literals', ->
    expr = ->
      if true
        return false
      else
        return true
  
    jua.translate(expr).should.eql "if true then\n  return false\nelse\n  return true\nend"
    
  it 'should support boolean expressions', ->
    expr = -> return true if 1 + 1 == 2
    jua.translate(expr).should.eql "if 1 + 1 == 2 then\n  return true\nend"

    expr = -> return true if 1 + 1 != 2
    jua.translate(expr).should.eql "if 1 + 1 ~= 2 then\n  return true\nend"
    
    expr = -> return true if not(1 + 1 == 2)
    jua.translate(expr).should.eql "if not(1 + 1 == 2) then\n  return true\nend"

    expr = -> return true if (1 + 1 == 2) and (3 + 4 == 7)
    jua.translate(expr).should.eql "if (1 + 1 == 2) and (3 + 4 == 7) then\n  return true\nend"

    expr = -> return true if (1 + 1 == 2) or !(3 + 4 == 7)
    jua.translate(expr).should.eql "if (1 + 1 == 2) or (not(3 + 4 == 7)) then\n  return true\nend"

  it 'should support chained else', ->
    expr = -> 
      if true
        return false
      else if 1 + 1 == 2
        return false
      else
        return true
        
    jua.translate(expr).should.eql "if true then\n  return false\nelseif 1 + 1 == 2 then\n  return false\nelse\n  return true\nend"