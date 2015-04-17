
parseColor = require "color-parser"
convert = require "color-convert"
add_css_function = require "./add-css-function"

debug = -> # console.log arguments...

current_node = null
parse = (value)->
	try
		(parseColor value) ? throw new Error "Failed to parse color value #{value}"
	catch e
		if current_node
			console.error e.stack
			throw current_node.error e.message
		else
			console.error "Error parsing color (with no associated CSS node)"
			throw e

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



for fn_name, fn of colorTransformers
	add_css_function fn_name, fn

