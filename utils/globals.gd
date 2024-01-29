extends Node

var rng := RandomNumberGenerator.new()

var turbo_mode

var horsies := []

var number_of_laps : int

var is_race_finished : bool

var is_official_race : bool

const WINNERS_FILE = "./past_winners"

func _ready():
	self.rng.randomize()
	self.pause_mode = PAUSE_MODE_PROCESS


func _unhandled_input(event: InputEvent):
#    print(event.as_text())
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
