
valueHook = require "./value-hook"

valueHook.add (str)->
	str.replace /([a-z\-]+) \(/ig, (m, fn_name)-> "#{fn_name}("

# module.exports = (str)-> str.replace /([a-z\-]+) \(/ig, (m, fn)-> "#{fn}("

# 	value_str.replace /([a-z\-]+) \(/ig,
# 		(m, function_name)-> "#{function_name}("
