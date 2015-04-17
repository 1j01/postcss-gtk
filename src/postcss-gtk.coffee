
postcss = require "postcss"

require "./fix-ugly-functions"
imports = require "postcss-import"
fixFontDeclarations = require "./fix-font-declarations"
gtkColorVariables = require "./color-variables"
require "./color-functions"
gtkPseudoClasses = require "./psuedo-classes"
valueHook = require "./value-hook"

module.exports =
	postcss [
		imports()
		fixFontDeclarations
		gtkColorVariables
		gtkPseudoClasses
		valueHook
	]

