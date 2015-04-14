
valueHook = require "./value-hook"

valueHook.add (str)->
	str.replace /([a-z\-]+) \(/ig, (m, fn_name)-> "#{fn_name}("
