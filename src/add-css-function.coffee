
balanced = require "balanced-match"
valueHook = require "./value-hook"
postcss = require "postcss"

module.exports = (fn_name, fn)->
	valueHook.add (str, node)->
		startIndex = str.indexOf(fn_name + "(")
		return str if startIndex is -1
		
		matches = balanced "(", ")", str.substring startIndex
		if matches
			args = postcss.list.comma matches.body
			args = (valueHook.hook arg for arg in args)
			pre = str.slice 0, startIndex
			post = str.substr startIndex + matches.end + 1
			
			current_node = node
			result = fn args...
			
			# @TODO: prevent infinite recursion
			return valueHook.hook pre + result + post
		else
			throw node.error "#{fn_name}(): missing closing ')' in the value #{JSON.stringify str}"
