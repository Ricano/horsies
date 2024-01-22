extends Node2D

onready var file = 'res://names'

var names : Array

onready var names_node = $Names

onready var n_laps_label = $SliderBackground/HSlider/Laps/Label
onready var slider = $SliderBackground/HSlider

onready var pop_up = $LastWinnersPopup
onready var winners_button = $LastWinnersButton

onready var tool_tip = $OfficialRaceCheckBox/Control/ToolTip


func _ready():
	get_photos_names()
	setup_names()


func _process(delta):
	n_laps_label.text = str(slider.value)


func _input(event):
	if pop_up.visible and event is InputEventMouseButton:
			pop_up.visible=false


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
		var face_sprite = Sprite.new()
		face_sprite.texture=face_texture 
		var container = HBoxContainer.new()
		var label = Label.new()
		var button = CheckButton.new()
		label.text = get_with_spaces(name)
		container.add_child(face_sprite)
		var vbox = VBoxContainer.new()
		container.add_child(vbox)
		button.set("custom_styles/focus",StyleBoxEmpty.new()) # remove the on hover borders around the buttons
		button.pressed = true
		vbox.add_child(button)
		button.add_child(label)
		label.margin_top -=10
		label.margin_left -=10
		names_node.add_child(container)
		face_sprite.global_position+=Vector2(-18, 18)

func get_with_spaces(name):
	var l = len(name)
	var empty_space = ""
	for _i in range(12-l):
		empty_space+=" "
	return empty_space + name
	


func _on_StartButton_pressed():
	globals.is_official_race = false
	if $OfficialRaceCheckBox.pressed:
		globals.is_official_race = true
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
		# if button is pressed (toggled on)
		if child.get_child(1).get_child(0).pressed:
			# get the associated label text
			result.append(child.get_child(1).get_child(0).get_child(0).text.strip_edges(true, true))
	return result


func _on_BackButton_pressed():
	get_tree().change_scene("res://ui/intro/intro_menu.tscn")


func _on_LastWinnersButton_pressed():
	pop_up.get_node("Label").text = get_last_winnners_info()
	pop_up.popup()


func get_last_winnners_info():
	return globals.file_load(globals.WINNERS_FILE)


func _on_Control_mouse_entered():
	tool_tip.show()


func _on_Control_mouse_exited():
	tool_tip.hide()
