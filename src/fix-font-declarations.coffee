
postcss = require "postcss"

module.exports = postcss.plugin "fix-font-declarations", ->
	(css, processor)->
		SIZE = /\d+(?:\.\d+)?(px|em|pt|pc|%|cm|mm|in|)/
		WEIGHT = /bold|light|normal/i
		css.eachDecl (decl)->
			if decl.prop is "font"
				unless decl.value is "initial"
					the_rest = decl.value
						.replace SIZE, (fontSize)->
							decl.parent.insertBefore decl,
								prop: "font-size"
								value: fontSize
							""
						.replace WEIGHT, (weight)->
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
		css.eachDecl (decl)->
			if decl.prop is "font-size"
				unless decl.value is "0"
					[fontSize, unit] = decl.value.match SIZE
					decl.value = "#{fontSize}pt" unless unit
				

# @TODO: implement the rest of https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-from-string
# Like how the documentation mentions STYLE_OPTIONS (and also STYLE-OPTIONS), which isn't in the given syntax? Fun.

