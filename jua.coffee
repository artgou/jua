jast = require('jast')
_ = require('underscore')
util = require('util')

Converter = {
  convert: (node) ->
    if this[node.type]
      this[node.type](node)
    else
      throw "I don't know how to translate #{node.type}:\n#{JSON.stringify(node)}"
    
  'script-context': (node) ->
    _.map(node.stats, (n) => @convert(n)).join('\n')
    
  'defn-stat': (node) ->
    @convert(node.closure)
    
  'closure-context': (node) ->
    _.map(node.stats, (n) => @convert(n)).join('\n')
    
  'expr-stat': (node) ->
    @convert(node.expr)
    
  'static-assign-expr': (node) ->
    
  'scope-assign-expr': (node) ->
    "#{node.value} = #{@convert(node.expr)}"
    
  'var-stat': (node) ->
    _.map(node.vars, (v) => 
      if v.expr
        "local #{v.value} = #{@convert(v.expr)}"
      else
        "local #{v.value}"
    ).join('\n')
    
  'num-literal': (node) ->
    node.value.toString()
    
  'str-literal': (node) ->
    util.inspect(node.value)
    
  'null-literal': (node) ->
    'nil'
    
  detectStringLiteral: (exprs) ->
    _.any exprs, (e) =>
      if e.type == 'add-op-expr'
        @detectStringLiteral([e.left, e.right])
      else
        e.type == 'str-literal'
    
  'add-op-expr': (node) ->
    if @detectStringLiteral([node.left, node.right])
      if (node.left.type == 'str-literal') && (node.left.value == '')
        @convert(node.right)
      else if (node.right.type == 'str-literal') && (node.right.value == '')
        @convert(node.left)
      else
        "#{@convert(node.left)} .. #{@convert(node.right)}"
    else
      "#{@convert(node.left)} + #{@convert(node.right)}"
      
  'mul-op-expr': (node) ->
    "#{@convert(node.left)} * #{@convert(node.right)}"
    
  'sub-op-expr': (node) ->
    "#{@convert(node.left)} - #{@convert(node.right)}"
    
  'scope-ref-expr': (node) ->
    node.value
    
  'ret-stat': (node) ->
    if node.expr.type == 'scope-assign-expr'
      "#{@convert(node.expr)}\nreturn #{node.expr.value}"
    else
      "return #{@convert(node.expr)}"
}

module.exports.translate = (expr, debug) ->
  if typeof(expr) == 'function'
    expr = "var closure = #{expr.toString()}"
    ast = jast.parse(expr).stats[0].vars[0].expr.closure
  else
    ast = jast.parse(expr)
    
  if debug
    console.log(JSON.stringify(ast, null, "  "))

  Converter.convert(ast)
  
