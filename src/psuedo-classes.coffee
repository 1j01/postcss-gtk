
postcss = require "postcss"

module.exports = postcss.plugin "gtk-color-variables", ->
	(css, processor)->
		css.eachRule (rule)->
			rule.selector = rule.selector
				.replace /:selected/g, ".selected"
				.replace /:insensitive/g, ":disabled"
				.replace /:inconsistent/g, ":indeterminate"
