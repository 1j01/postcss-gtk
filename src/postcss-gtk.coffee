
postcss = require "postcss"

require "./fix-ugly-functions"
imports = require "postcss-import"
fixFontDeclarations = require "./fix-font-declarations"
gtkColorVariables = require "./color-variables"
gtkColorFunctions = require "./color-functions"
gtkPseudoClasses = require "./psuedo-classes"
valueHook = require "./value-hook"

module.exports =
	postcss [
		imports()
		fixFontDeclarations
		gtkColorVariables
		gtkColorFunctions
		gtkPseudoClasses
		valueHook
	]

