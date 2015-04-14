
postcss = require "postcss"
# reworkFunctions = require "rework-plugin-function"
# reworkImports = require "rework-import"
tryToParseColor = require "color-parser"
convert = require "color-convert"


parse = (value)-> (tryToParseColor value) ? throw new Error "Failed to parse color value #{value}"

lerp = (a, b, x)-> a + (b - a) * x
rgba = (r, g, b, a)->
	if isNaN a or a is 1
		"rgb(#{~~r}, #{~~g}, #{~~b})"
	else
		"rgba(#{~~r}, #{~~g}, #{~~b}, #{a})"

colorTransformers =
	mix: (colorA, colorB, x)->
		console.log "MIX COLORS #{colorA} AND #{colorB} BY LERPY AMOUNT #{x}"
		a = parse colorA
		b = parse colorB
		console.log "-", colorA, a
		console.log "-", colorB, b
		console.log "-", x
		
		l = (p)-> lerp a[p], b[p], x
		rgba(
			l "r"
			l "g"
			l "b"
			l "a"
		)
	
	shade: (color, value)->
		[color, value] = [value, color] if isNaN value
		console.log "SHADE COLOR #{color} BY VALUE #{value}"
		
		{r, g, b, a} = parse color
		
		[h, s, l] = convert.rgb2hslRaw r, g, b
		console.log "- OLD LIGHTNESS: #{l}"
		l *= value # @FIXME
		console.log "- NEW LIGHTNESS: #{l} (AFTER APPLYING #{value})"
		[r, g, b] = convert.hsl2rgb h, s, l
		
		rgba(r, g, b, a)
	
	alpha: (color, factor)->
		[color, factor] = [factor, color] if isNaN factor
		console.log "MULTIPLY ALPHA OF COLOR #{color} BY FACTOR #{factor}"
		
		{r, g, b, a} = parse color
		
		console.log "- OLD", rgba(r, g, b, a)
		a *= factor
		console.log "- NEW", rgba(r, g, b, a)
		
		# @TODO: handle %
		
		rgba(r, g, b, a)



refunc = require "reduce-function-call"

valueHook = require "./value-hook"


valueHook.add (str, node)->
	
	for fn_name, fn of colorTransformers
		if str.indexOf(fn_name) isnt -1
			try
				str = refunc str, fn_name, (body, functionIdentifier, call)->
					args = postcss.list.comma body
					# console.log fn_name, args
					args = (valueHook.hook arg for arg in args)
					# console.log fn_name, args
					console.log "REFUNCTION", str, fn_name, args
					str.replace call, fn args...
				# 	str
				# console.log "AFTER REFUNCTION", r
				# str
			catch e
				throw node.error "Function call? What? #{e}"
			# str.replace /@([a-z_\-]+)/i, (m, name)->
			# 	if color_vars[name]
			# 		console.log name, "=", color_vars[name]
			# 		valueHook.hook color_vars[name], node
			# 	else
			# 		throw node.error ""
	str



module.exports = postcss.plugin "gtk-color-functions", ->
	(css, processor)->
		
