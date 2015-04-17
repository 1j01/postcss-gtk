
postcss = require "postcss"
tryToParseColor = require "color-parser"
convert = require "color-convert"

debug = -> # console.log arguments...

current_node = null
parse = (value)->
	try
		(tryToParseColor value) ? throw new Error "Failed to parse color value #{value}"
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



# refunc = require "reduce-function-call"
balanced = require "balanced-match"

valueHook = require "./value-hook"

add_css_function = (fn_name, fn)->
	valueHook.add (str, node)->
		startIndex = str.indexOf(fn_name + "(")
		return str if startIndex is -1
		
		matches = balanced "(", ")", str.substring startIndex
		# console.log str, fn_name, matches #, str.substring startIndex
		if matches
			# console.log "matches.post:", matches.post
			# console.log "   substring:", str.substr matches.end
			args = postcss.list.comma matches.body
			args = (valueHook.hook arg for arg in args)
			pre = str.slice 0, startIndex
			post = str.substr startIndex + matches.end + 1
			# console.log "STR", str
			# console.log "---", (str.slice 0, startIndex) + fn_name + "(" + matches.body + (str.substr startIndex + matches.end)
			# console.assert str is (str.slice 0, startIndex) + fn_name + "(" + matches.body + (str.substr startIndex + matches.end)
			# console.log "doing", fn_name+"()", "in", str#JSON.stringify str
			# console.log "PRE+POST:", (str.slice 0, startIndex) + (str.substr startIndex + matches.end + 1)
			# console.log "pre+post:", pre + post
			
			current_node = node
			result = fn args...
			
			# return result + post
			# console.warn " << ", str
			# console.warn " >> ", pre + result + post
			return valueHook.hook pre + result + post
		else
			# this should never occur, since PostCSS checks for mismatched parenthesis before processing... right?
			# process.stderr.write "#{str} OUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUTOUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUTOUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUTOUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUTOUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUTOUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUTOUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUTOUTPUTOUTPOUTPOUTOPUTOUTPOTUOPTUPOUT"
			# throw new SyntaxError "#{fn_name}(): missing closing ')' in the value #{JSON.stringify str}"
			# return "#{fn_name}(): missing closing ')' in the value #{JSON.stringify str}"
			console.log args
			console.log "#{fn_name}(): missing closing ')' in the value #{JSON.stringify str}"
			return "BLUE"

for fn_name, fn of colorTransformers
	add_css_function fn_name, fn



module.exports = postcss.plugin "gtk-color-functions", ->
	(css, processor)->
		
