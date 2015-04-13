
rework = require "rework"
reworkFunctions = require "rework-plugin-function"
reworkImports = require "rework-import"
tryToParseColor = require "color-parser"
convert = require "color-convert"

parse = (value)-> (tryToParseColor value) ? throw new Error "Failed to parse color value #{value}"

lerp = (a, b, x)-> a + (b - a) * x
rgba = (r, g, b, a)->
	if isNaN a or a is 1
		"rgb(#{~~r}, #{~~g}, #{~~b})"
	else
		"rgba(#{~~r}, #{~~g}, #{~~b}, #{a})"

colorTranformers =
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

preprocess = (gtk_css)->
	# replace syntax that doesn't parse
	# create temporary @define-color { ... } rules
	# If I did this right, it should preserve line numbers
	# console.log "preprocessing"
	gtk_css.replace /@define-color (\w+) (.*)/gim, "@define-color { $1: $2; }"

fix_ugly_function_calls = (value_str)->
	value_str.replace /([a-z\-]+) \(/ig,
		(m, function_name)-> "#{function_name}("

module.exports = (gtk_css, options)->
	
	throw new Error "options object required" unless options
	{import_path} = options
	throw new Error "options.import_path is required for @imports" unless import_path
	
	color_vars = {}
	
	expand_vars = (value_str)->
		VARIABLE = /@([a-z_\-]+)/ig
		while value_str.match VARIABLE
			value_str = value_str.replace VARIABLE,
				(m, var_name)->
					# console.log "REFERENCE VARIABLE #{var_name} (VALUE: #{color_vars[var_name]})"
					console.log "REFERENCE VARIABLE #{var_name}"
					color_vars[var_name] ? throw new Error "Color variable #{var_name} has not been defined"
					console.log " - - - - - VALUE = #{color_vars[var_name]}"; color_vars[var_name]
		value_str
	
	(rework (preprocess gtk_css)).use (styles)->
		
		{rules} = styles
		(reworkImports path: import_path, transform: preprocess) styles
		{rules} = styles
		
		# handle temporary @define-color { ... } rules
		rules = styles.rules = styles.rules.filter (rule)->
			if rule.selectors?[0] is "@define-color"
				for declaration in rule.declarations
					{property: var_name, value} = declaration
					# console.log "DEFINE COLOR #{var_name} AS #{value}"
					value = fix_ugly_function_calls value
					color_vars[var_name] = value
					# console.log "- (COMPUTED) #{var_name} AS #{value}"
					console.log "DEFINE COLOR #{var_name} AS #{value}"
				no # discard 
			else
				yes # keep
		
		# console.log JSON.stringify rules, null, "  "
		for rule in rules when rule.declarations
			
			# replace gtk pseudo-classes
			rule.selectors = for selector in rule.selectors
				selector
					.replace /:selected/, ".selected"
					.replace /:insensitive/, ":disabled"
					.replace /:inconsistent/, ":indeterminate"
			
			# @TODO walk the rest of the tree (@keyframes)
			for declaration in rule.declarations when declaration.type is "declaration"
				declaration.value =
					fix_ugly_function_calls expand_vars declaration.value
		
		# apply color functions
		(reworkFunctions colorTranformers) {rules}
		
		# mutate the styles
		styles.rules = rules

