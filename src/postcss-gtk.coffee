
postcss = require "postcss"

require "./fix-ugly-functions"
imports = require "postcss-import"
gtkColorVariables = require "./color-variables"
gtkColorFunctions = require "./color-functions"
valueHook = require "./value-hook"

module.exports =
	postcss [
		imports()
		gtkColorVariables
		gtkColorFunctions
		valueHook
	]



# {rules} = styles
# (reworkImports path: import_path, transform: preprocess) styles
# {rules} = styles
# 
# # handle temporary @define-color { ... } rules
# rules = styles.rules = styles.rules.filter (rule)->
# 	if rule.selectors?[0] is "@define-color"
# 		for declaration in rule.declarations
# 			{property: var_name, value} = declaration
# 			# console.log "DEFINE COLOR #{var_name} AS #{value}"
# 			value = fix_ugly_function_calls value
# 			color_vars[var_name] = value
# 			# console.log "- (COMPUTED) #{var_name} AS #{value}"
# 			console.log "DEFINE COLOR #{var_name} AS #{value}"
# 		no # discard 
# 	else
# 		yes # keep
# 
# # console.log JSON.stringify rules, null, "  "
# for rule in rules when rule.declarations
# 	
# 	# replace gtk pseudo-classes
# 	rule.selectors = for selector in rule.selectors
# 		selector
# 			.replace /:selected/, ".selected"
# 			.replace /:insensitive/, ":disabled"
# 			.replace /:inconsistent/, ":indeterminate"
# 	
# 	# @TODO walk the rest of the tree (@keyframes)
# 	for declaration in rule.declarations when declaration.type is "declaration"
# 		declaration.value =
# 			fix_ugly_function_calls expand_vars declaration.value
# 
# # apply color functions
# (reworkFunctions colorTranformers) {rules}

