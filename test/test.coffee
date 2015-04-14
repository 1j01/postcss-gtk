
{readFileSync: read, writeFileSync: write} = require "fs"
{join} = require "path"
glob = require "glob"
mkdirp = require "mkdirp"

try
	require "coffee-script/register"
	postgtk = require "../src/postcss-gtk.coffee"
catch e
	console.error "Failed to load postcss-gtk.coffee (in development)\n"
	throw e unless /Cannot find module/.exec e
	postgtk = require ".."

cwd = join __dirname, "fixtures"
fixtures = "{*,**/gtk}.css"
# fixtures = "**/gtk.css"
# fixtures = "test.css"

for file_path, i in glob.sync fixtures, {cwd, debug: off}
	do (file_path, i)->
		file_name = file_path.replace(/.*\//, "")
		file_path = join cwd, file_path
		file_dir = file_path.replace /[\/\\][^\/\\]+$/, ""
		
		console.log """
		 _
		| |  _
		| | | |  _   Test #{i+1}: #{file_name}
		| |_| |_| |_______________________________________
		
		"""
		gtk_css = read file_path, "utf8"
		
		# vars =
		# 	fg_color: "black"
		# 	# bg_color: "rgba(235,255,255,0.9)"
		# 	bg_color: "rgba(235, 255, 255, 0.9)"
		# 	# bg_color: "white"
		# 	selected_bg_color: "blue"
		# 	selected_fg_color: "white"
		# 	tooltip_bg_color: "rgb(255,255,200)"
		# 	tooltip_fg_color: "red"
		# 	base_color: "green"
		# 	text_color: "aqua"
		
		output_path = file_path.replace "fixtures", "output"
		source_map_output_path = "#{output_path}.map"
		output_dir = output_path.replace /[\/\\][^\/\\]+$/, ""
		mkdirp.sync output_dir
		
		postgtk
			.process gtk_css, from: file_path, to: output_path
			.then (result)->
				write output_path, result.css, "utf8"
				write source_map_output_path, result.map, "utf8" if result.map
			.catch (e)->
				console.error e.stack

