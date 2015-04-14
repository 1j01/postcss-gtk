
postcss = require "postcss"

# @FIXME don't use a global list
valueHooks = []

module.exports = postcss.plugin "gtk-color-variables", ->
	(css, processor)->
		css.eachDecl (decl)->
			decl.value = module.exports.hook decl.value, decl

module.exports.hook = (value, node)->
	str = value
	for fn in valueHooks
		str = fn str, node
		if typeof str isnt "string"
			throw new Error "Value hook returned #{typeof str}"
	console.log "before hook:", value
	console.log "after hook:", str
	str

module.exports.add = (hook)->
	valueHooks.push hook

