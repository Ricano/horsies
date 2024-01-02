extends Node2D

onready var file = 'res://names'

var names : Array

onready var names_node = $Names

func _ready():
	load_file(file)
	setup_names()

func load_file(file):
	
	var f = File.new()
	f.open(file, File.READ)
	var index = 1
	print("############ Loaded horsies ############")
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		if line:
			names.append(line)
			print(line)
		index += 1
	f.close()
	print()
	return

func setup_names():
	for name in names:
		var face_texture = load("res://horsie/faces/" + str(name) + ".png")
		var container = HBoxContainer.new()
		var label = Label.new()
		var button = CheckButton.new()
		var extra_space = 16-len(name)
		label.text = get_with_spaces(name)
		button.icon = face_texture
		button.pressed = true
		container.add_child(label)
		container.add_child(button)
		names_node.add_child(container)


func get_with_spaces(name):
	var l = len(name)
	var empty_space = ""
	for i in range(12-l):
		empty_space+=" "
	return empty_space + name
	


func _on_StartButton_pressed():
	var result = get_active_names()
	print("############ Selected horsies ############")
	for x in result:
		print(x)
	
	if len(result) >= 2:
		globals.horsies = result
		get_tree().change_scene("res://terrain/terrain.tscn")
	else:
		# Todo: make a warning popup
		pass
		
	

func get_active_names():
	var result := []
	for child in names_node.get_children():
		if child.get_child(1).pressed:
			result.append(child.get_child(0).text.strip_edges(true, true))
	return result
	
