
postcss = require "postcss"
tryToParseColor = require "color-parser"
convert = require "color-convert"

debug = -> # console.log arguments...

parse = (value)-> (tryToParseColor value) ? throw new Error "Failed to parse color value #{value}"

lerp = (a, b, x)-> a + (b - a) * x
rgba = (r, g, b, a)->
	if isNaN(a) or a is 1
		"rgb(#{~~r}, #{~~g}, #{~~b})"
	else
		"rgba(#{~~r}, #{~~g}, #{~~b}, #{a})"

colorTransformers =
	mix: (colorA, colorB, x)->
		debug "MIX COLORS #{colorA} AND #{colorB} BY LERPY AMOUNT #{x}"
		a = parse colorA
		b = parse colorB
		debug "-", colorA, a
		debug "-", colorB, b
		debug "-", x
		
		l = (p)-> lerp a[p], b[p], x
		rgba(
			l "r"
			l "g"
			l "b"
			l "a"
		)
	
	shade: (color, value)->
		[color, value] = [value, color] if isNaN value
		debug "SHADE COLOR #{color} BY VALUE #{value}"
		
		{r, g, b, a} = parse color
		
		[h, s, l] = convert.rgb2hslRaw r, g, b
		debug "- OLD LIGHTNESS: #{l}"
		l *= value # @FIXME
		debug "- NEW LIGHTNESS: #{l} (AFTER APPLYING #{value})"
		[r, g, b] = convert.hsl2rgb h, s, l
		
		rgba(r, g, b, a)
	
	alpha: (color, factor)->
		[color, factor] = [factor, color] if isNaN factor
		debug "MULTIPLY ALPHA OF COLOR #{color} BY FACTOR #{factor}"
		
		{r, g, b, a} = parse color
		
		debug "- OLD", rgba(r, g, b, a)
		a *= factor
		debug "- NEW", rgba(r, g, b, a)
		
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
					args = (valueHook.hook arg for arg in args)
					str.replace call, fn args...
			catch e
				throw node.error "Function call? What? #{e}"
	str



module.exports = postcss.plugin "gtk-color-functions", ->
	(css, processor)->
		
