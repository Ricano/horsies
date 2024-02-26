extends Node2D

onready var file = 'res://names'

var names : Array

onready var names_node = $Names

onready var n_laps_label = $SliderBackground/HSlider/Laps/Label
onready var slider = $SliderBackground/HSlider

onready var past_winners_label = $past_winners/Label

onready var tool_tip = $OfficialRaceCheckBox/Control/ToolTip


func _ready():
	past_winners_label.text = get_last_winnners_info()
	
	setup_names()


func _process(delta):
	n_laps_label.text = str(slider.value)


func setup_names():
	globals.get_names_from_photos(names, "res://horsie/faces/")
	names = globals.eliminate_duplicates(names)
	names.sort()
	create_checkboxes()


func create_checkboxes():
	for name in names:
		var face_texture = load("res://horsie/faces/" + str(name) + ".png")
		var face_sprite = Sprite.new()
		face_sprite.texture=face_texture 
		
		var container = HBoxContainer.new()
		container.name = name
		var label = Label.new()
		var button = CheckButton.new()
		label.text = get_with_spaces(name)
		container.add_child(face_sprite)
		
		var vbox = VBoxContainer.new()
		vbox.margin_top = 100
		
		container.add_child(vbox)
		button.set("custom_styles/focus",StyleBoxEmpty.new()) # remove the on hover borders around the buttons
		button.pressed = true
		vbox.add_child(button)
		button.add_child(label)
		label.margin_top -=10
		label.margin_left -=10
		vbox.margin_top = 100
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
	
	for name in names:
		if not name in result:
			globals.not_racing.append(name)
		
	print("not_racing", globals.not_racing)

	
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



func get_last_winnners_info():
	return globals.file_load(globals.WINNERS_FILE)


func _on_Control_mouse_entered():
	tool_tip.show()


func _on_Control_mouse_exited():
	tool_tip.hide()


func _on_past_winners_toggle_pressed():
	var past_winners = get_past_winners_without_duplicates()
	
	toggle_past_winners_participation(past_winners)


func toggle_past_winners_participation(past_winners):
	for node in names_node.get_children():
		for winner in past_winners:
			if node.name == winner:
				for child in node.get_children():
					if child is VBoxContainer:
						var button = child.get_child(0)
						button.pressed = !button.pressed



func get_past_winners_without_duplicates():
	var win_info = get_last_winnners_info()
	var n = get_winners_name(win_info)
	return n


func get_winners_name(win_info):
	var chars = []
	for c in win_info:
		var char_code = ord(c)
		if (char_code==ord(" ") or char_code >= ord("a") and char_code <= ord("z")) or (char_code >= ord("A") and char_code <= ord("Z")) or (char_code >= ord("à") and char_code <= ord("ÿ")):
			chars.append(c)
	
	var unique_names = globals.eliminate_duplicates(get_names(chars))
	return unique_names


func get_names(input_array):
	var result = []
	var current_name = ""
	for c in input_array:
		if c == " ":
			if current_name != "":
				result.append(current_name)
				current_name = ""
		else:
			current_name += c
	if current_name != "":
		result.append(current_name)
	return result


