extends Node2D

onready var file = 'res://names'

var names : Array

onready var names_node = $Names

onready var n_laps_label = $SliderBackground/HSlider/Laps/Label
onready var slider = $SliderBackground/HSlider



func _ready():
	get_photos_names()
	setup_names()


func _process(delta):
	n_laps_label.text = str(slider.value)
	
	
func get_photos_names():
	var folder_path = "res://horsie/faces/"
	var dir = Directory.new()
	if dir.open(folder_path) == OK:
		dir.list_dir_begin(true,true)
		var file_name = dir.get_next()
		while file_name != "":
			names.append(file_name.split(".")[0])
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory:", folder_path)
	
	names = eliminate_duplicates(names)
	names.sort()
	print("############ Loaded horsies ############")
	print(names)


func eliminate_duplicates(array: Array) -> Array:
	var unique := []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique




func setup_names():
	for name in names:
		var face_texture = load("res://horsie/faces/" + str(name) + ".png")
		var container = HBoxContainer.new()
		var label = Label.new()
		var button = CheckButton.new()
		label.text = get_with_spaces(name)
		label.margin_left += 55
		label.margin_top += 5
		button.icon = face_texture
		button.set("custom_styles/focus",StyleBoxEmpty.new())
		button.pressed = true
		button.add_child(label)
		container.add_child(button)
		names_node.add_child(container)


func get_with_spaces(name):
	var l = len(name)
	var empty_space = ""
	for _i in range(12-l):
		empty_space+=" "
	return empty_space + name
	


func _on_StartButton_pressed():
	var result = get_active_names()
	print("############ Selected horsies ############")
	randomize()
	result.shuffle()
	
	for x in result:
		print(x)
	
	if len(result) >= 2:
		globals.horsies = result
		globals.number_of_laps = slider.value
		get_tree().change_scene("res://terrain/terrain.tscn")
	else:
		# Todo: make a warning popup
		pass
	

func get_active_names():
	var result := []
	for child in names_node.get_children():
		if child.get_child(0).pressed:
			result.append(child.get_child(0).get_child(0).text.strip_edges(true, true))
	return result
	

