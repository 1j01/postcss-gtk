
postcss = require "postcss"
valueHook = require "./value-hook"

color_vars = {}

valueHook.add (str, node)->
	str.replace /@([a-z_\-]+)/i, (m, name)->
		if color_vars[name]
			valueHook.hook color_vars[name], node
		else
			throw node.error "Color variable #{name} has not been defined"

module.exports = postcss.plugin "gtk-color-variables", ->
	(css, processor)->
		css.eachAtRule (node)->
			if node.name is "define-color"
				[_, name, value] = node.params.match /(\S+)\s+(.*)/
				color_vars[name] = value
				node.removeSelf()

