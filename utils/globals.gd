extends Node

var rng := RandomNumberGenerator.new()

var turbo_mode

var horsies := []
var not_racing := []

var number_of_laps : int

var is_race_finished : bool

var is_official_race : bool

const WINNERS_FILE = "./past_winners"

func _ready():
	self.rng.randomize()
	self.pause_mode = PAUSE_MODE_PROCESS


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		var tree := self.get_tree()
		tree.paused = not tree.paused
	if event.is_action_pressed("ui_focus_next"):
		Engine.time_scale = 0.25 if Engine.time_scale == 1.0 else 1.0
	if event.is_action_pressed("ui_cancel"):
		Engine.time_scale = 1.0
		self.get_tree().reload_current_scene()

func file_save(path, content):
	var old_content = file_load(path)
	var new_content = old_content + "\n" + content
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(new_content)
	file.close()

func file_load(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func get_names_from_photos(names_array, folder):
	var folder_path = folder
	var dir = Directory.new()
	if dir.open(folder_path) == OK:
		dir.list_dir_begin(true,true)
		var file_name = dir.get_next()
		while file_name != "":
			names_array.append(file_name.split(".")[0])
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Failed to open directory:", folder_path)




func eliminate_duplicates(array: Array) -> Array:
	var unique := []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique
