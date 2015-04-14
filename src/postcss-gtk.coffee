
postcss = require "postcss"

require "./fix-ugly-functions"
imports = require "postcss-import"
gtkColorVariables = require "./color-variables"
gtkColorFunctions = require "./color-functions"
gtkPseudoClasses = require "./psuedo-classes"
valueHook = require "./value-hook"

module.exports =
	postcss [
		imports()
		gtkColorVariables
		gtkColorFunctions
		gtkPseudoClasses
		valueHook
	]

