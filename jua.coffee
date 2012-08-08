jast = require('jast')
_ = require('underscore')
util = require('util')

Converter = {
  convert: (node, args...) ->
    if typeof(node) == 'string'
      node
    else if this[node.type]
      this[node.type](node, args...)
    else
      throw "I don't know how to translate #{node.type}:\n#{JSON.stringify(node)}"
      
  _indent: (str) ->
    _.map(str.split("\n"), (l) -> "  #{l}").join("\n")
    
  'script-context': (node) ->
    _.map(node.stats, (n) => @convert(n)).join('\n')
    
  'defn-stat': (node) ->
    @convert(node.closure)
    
  'closure-context': (node) ->
    _.map(node.stats, (n) => @convert(n)).join('\n')
    
  'block-stat': (node) ->
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
    
  'boolean-literal': (node) ->
    node.value.toString()
    
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
    
  'eqs-op-expr': (node) ->
    "#{@convert(node.left)} == #{@convert(node.right)}"
    
  'neqs-op-expr': (node) ->
    "#{@convert(node.left)} ~= #{@convert(node.right)}"
    
  'not-op-expr': (node) ->
    "not(#{@convert(node.expr)})"
    
  'and-op-expr': (node) ->
    "(#{@convert(node.left)}) and (#{@convert(node.right)})"
    
  'or-op-expr': (node) ->
    "(#{@convert(node.left)}) or (#{@convert(node.right)})"
    
  'scope-ref-expr': (node) ->
    node.value
    
  'ret-stat': (node) ->
    if node.expr.type == 'scope-assign-expr'
      "#{@convert(node.expr)}\nreturn #{node.expr.value}"
    else
      "return #{@convert(node.expr)}"
      
  'call-expr': (node) ->
    # detect conversion to number
    if (node.expr.type == 'scope-ref-expr') && (node.expr.value == 'Number')
      fn_expr = 'tonumber'
    else if (node.expr.type == 'scope-ref-expr') && (node.expr.value == 'String')
      fn_expr = 'tostring'
    else
      fn_expr = @convert(node.expr)
    
    "#{fn_expr}(#{@_args(node.args)})"
    
  _args: (args) ->
    _.map(args, (a) => @convert(a)).join(', ')
    
  'static-method-call-expr': (node) ->
    if (node.value == 'toString') && (node.args.length == 0)
      "tostring(#{@convert(node.base)})"
    else
      "#{@convert(node.base)}.#{node.value}(#{@_args(node.args)})"
      
  'if-stat': (node, terminate = true) ->
    block = "if #{@convert(node.expr)} then\n#{@_indent(@convert(node.thenStat))}\n"
    if node.elseStat && (node.elseStat.type == 'if-stat')
      block += "else#{@convert(node.elseStat, false)}"
    else if node.elseStat
      block += "else\n#{@_indent(@convert(node.elseStat))}\n"
    block += "end" if terminate
    
    block
    
  'func-literal': (node) ->
    "function(#{node.closure.args.join(', ')})\n#{@_indent(_.map(node.closure.stats, (n) => @convert(n)).join('\n'))}\nend"

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
  
