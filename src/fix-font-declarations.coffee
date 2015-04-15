
postcss = require "postcss"

module.exports = postcss.plugin "fix-font-declarations", ->
	(css, processor)->
		css.eachDecl (decl)->
			if decl.prop is "font"
				unless decl.value is "initial"
					the_rest = decl.value
						.replace /\d+(?:\.\d+)?(px|em|pt|)/, (fontSize, decimal, unit)->
							fontSize = "#{fontSize}pt" unless unit
							decl.parent.insertBefore decl,
								prop: "font-size"
								value: fontSize
							""
						.replace /bold|light|normal/i, (weight)->
							fontWeight = weight.toLowerCase()
							fontWeight = "300" if fontWeight is "light"
							decl.parent.insertBefore decl,
								prop: "font-weight"
								value: fontWeight
							""
					fontFamily = the_rest.trim()
					if fontFamily
						decl.parent.insertBefore decl,
							prop: "font-family"
							value: '"' + fontFamily + '"'
					decl.removeSelf()
					

