
postcss = require "postcss"

module.exports = postcss.plugin "gtk-color-variables", ->
	(css, processor)->
		css.eachRule (rule)->
			rule.selector = rule.selector
				.replace /:selected/g, ".selected"
				.replace /:insensitive/g, ":disabled"
				.replace /:inconsistent/g, ":indeterminate"
				.replace /:prelight/g, ":hover"
				.replace /:focused/g, ":focus"
			
			if (rule.selector.indexOf ":backdrop") isnt -1
				selectors = for selector in postcss.list.comma rule.selector
					sel = selector
					if (sel.indexOf ":backdrop") isnt -1
						sel = ".window-frame:not(.active) " + sel.replace ":backdrop", ""
					if (sel.indexOf ":backdrop") isnt -1
						throw rule.error "Unnecessary extra :backdrop in #{JSON.stringify selector}"
					sel
				rule.selector = selectors.join ",\n"
