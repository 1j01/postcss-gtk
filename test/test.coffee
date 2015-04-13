
{readFileSync: read, writeFileSync: write} = require "fs"
{join} = require "path"
glob = require "glob"
mkdirp = require "mkdirp"

rework_gtk = require ".."
try
	require "coffee-script/register"
	rework_gtk = require "../src/rework-gtk.coffee"
catch e
	console.error "Failed to load rework-gtk.coffee (in development)\n"
	# console.error "#{e}"
	throw e

cwd = join __dirname, "fixtures"
# fixtures = "{*,**/gtk}.css"
fixtures = "**/gtk.css"
# fixtures = "test.css"

for file_path, i in glob.sync fixtures, {cwd, debug: off}
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
	
	vars =
		fg_color: "black"
		# bg_color: "rgba(235,255,255,0.9)" # @FIXME this breaks shade() at least
		bg_color: "rgba(235, 255, 255, 0.9)"
		# bg_color: "white"
		selected_bg_color: "blue"
		selected_fg_color: "white"
		tooltip_bg_color: "rgb(255,255,200)"
		tooltip_fg_color: "red"
		base_color: "green"
		text_color: "aqua"
	
	css = "#{rework_gtk gtk_css, import_path: file_dir}"
	
	output_path = file_path.replace "fixtures", "output"
	output_dir = output_path.replace /[\/\\][^\/\\]+$/, ""
	mkdirp.sync output_dir
	write output_path, css, "utf8"

