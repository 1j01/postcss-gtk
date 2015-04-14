
postcss = require "postcss"

valueHook = require "./value-hook"

color_vars = {}

valueHook.add (str, node)->
	str.replace /@([a-z_\-]+)/i, (m, name)->
		if color_vars[name]
			console.log name, "=", color_vars[name]
			valueHook.hook color_vars[name], node
		else
			throw node.error "Color variable #{name} has not been defined"

module.exports = postcss.plugin "gtk-color-variables", ->
	(css, processor)->
		css.eachInside (node)->
			if node.type is "atrule" and node.name is "define-color"
				[_, name, value] = node.params.match /(\S+)\s+(.*)/
				console.log "DEFINE #{name} AS #{value}"
				color_vars[name] = value
				node.removeSelf()
		
		# css.replaceValues /@([a-z_\-]+)/i, fast: "@", (m, name)->
		# 	color_vars[name] ? throw new Error "Color variable #{name} has not been defined"



# color_vars = {}
# 
# expand_vars = (value_str)->
# 	VARIABLE = /@([a-z_\-]+)/ig
# 	while value_str.match VARIABLE
# 		value_str = value_str.replace VARIABLE,
# 			(m, name)->
# 				# console.log "REFERENCE VARIABLE #{name} (VALUE: #{color_vars[name]})"
# 				console.log "REFERENCE VARIABLE #{name}"
# 				color_vars[name] ? throw new Error "Color variable #{name} has not been defined"
# 				console.log " - - - - - VALUE = #{color_vars[name]}"; color_vars[name]
# 	value_str




