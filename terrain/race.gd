extends Node

onready var black_screen = $black_screen

var sound_time_delay: float

var n_laps := globals.number_of_laps
var laps := {}
var progress := {}
var ranks := {}

var horsie_scene = preload("res://horsie/horsie.tscn")
var ultra_scene = preload("res://ultra/ultra.tscn")


var colors := [
	Color.red,
	Color.royalblue,
	Color.orangered,
	Color.purple,
	Color.yellow,
	Color.aqua,
	Color.brown,
	Color.coral,
	Color.cornflower,
	Color.crimson,
	Color.cyan,
	Color.deeppink,
	Color.dodgerblue,
	Color.gold,
	]


func _ready():
	

	
	Engine.time_scale = 1
	
	if globals.turbo_mode:
		$utils/turbo_music.play()
		$crowd_area/crowd_sound.play()
		
	else:
		$utils/music.play()

	sound_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	yield(get_tree().create_timer(sound_time_delay), "timeout")
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(black_screen, "global_position", black_screen.global_position, black_screen.global_position + Vector2(0,-1000), 1, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	
	globals.is_race_finished = false
	self.process_priority = +1  # to process this node after horsies



	set_up_horsies()
	set_up_ultras()

	var tree := self.get_tree()
#	tree.paused = true

	var track: Path2D = $track
	var horsies := $objects/horsies.get_children()
	for i in range(horsies.size()):
		var horsie = horsies[i]
		horsie.set_process(false)
		horsie.setup(track, i)
		horsie.connect("lap_completed", self, "_on_lap_completed", [horsie])
		self.laps[horsie] = 0
		self.progress[horsie] = 0.0
		self.ranks[horsie] = 1

	$gui/anim.play("countdown")

	# Display status line every second.
	while true:
		var status := PoolStringArray()
		for horsie in horsies:
			var progress_pct = "%.02f" % (self.progress[horsie] * 100)
			status.append("{0} #{1} {2}%".format([horsie.name, self.ranks[horsie], progress_pct]))
		# print(status.join(" | "))
		yield(tree.create_timer(1), "timeout")


func _process(delta):

	# Update horsie progress.
	var horsies := $objects/horsies.get_children()
	for horsie in horsies:
		self.progress[horsie] = (self.laps[horsie] + horsie.follow.unit_offset) / self.n_laps

	# Compute horsie ranks.
	horsies.sort_custom(self, "_horsies_order")
	var rank := 0
	var progress := -1.0
	self.ranks.clear()
	for i in range(horsies.size()):
		horsies[i].is_last = false
		var horsie = horsies[i]
		var horsie_progress = self.progress[horsie]
		if horsie_progress != progress:
			progress = horsie_progress
			rank = i + 1
		horsie.rank = rank
		self.ranks[horsie] = rank
		if rank == horsies.size():
#			 and laps[horsies[i]]>0:
			horsies[i].is_last = true
			
	# Update ranks and laps UI.
	if not globals.is_race_finished:
		var ranks := PoolStringArray()
		var current_lap := 0
		ranks.append("       STANDINGS")
		for horsie in horsies:
			ranks.append("   [color=#{color}]{rank}.   {name}[/color]".format({
				color=horsie.tint.to_html(),
				rank=self.ranks[horsie],
				name=horsie.name
			}))
			current_lap = max(current_lap, self.laps[horsie] + 1)

		if current_lap > 0:
			$gui/ranks.bbcode_text = ranks.join("\n")
			$gui/ranks.set_fit_content_height(true)
			if current_lap <= self.n_laps:
				$gui/laps.text = "Lap {0} of {1}".format([current_lap, self.n_laps])
			else:
				$gui/laps.text = ""
	

func set_up_ultras():
	var ultras: Array
	globals.get_names_from_photos(ultras, "res://horsie/other_faces/")
	ultras = globals.eliminate_duplicates(ultras)
	
	var i = 0
	for name in ultras:
		var r = rand_range(-10, 10)
		var new_ultra = ultra_scene.instance()
		new_ultra.name = name
		var face_texture = load("res://horsie/other_faces/" + str(name) + ".png")
		new_ultra.set_face(face_texture)
		$objects/ultras.add_child(new_ultra)
		new_ultra.global_position.x += 26 * i + r 
		i += 1
	i-=1
	globals.not_racing.shuffle()
	for name in globals.not_racing:
		var r = rand_range(20, 40)
		var new_ultra = ultra_scene.instance()
		new_ultra.name = name
		var face_texture = load("res://horsie/faces/" + str(name) + ".png")
		new_ultra.set_face(face_texture)
		$objects/ultras.add_child(new_ultra)
		new_ultra.global_position.x += 26 * i + r 
		i += 1
	


func set_up_horsies():
	var i = 0
	for name in globals.horsies:
		var new_horsie = horsie_scene.instance()
		new_horsie.name = name
		new_horsie.tint = colors[i]
		$objects/horsies.add_child(new_horsie)
		i += 1

func _horsies_order(h1, h2):
	return self.progress[h1] >= self.progress[h2]


func _on_countdown_finished():
	"""Called during the "countdown" animation when the clock reaches zero. This is done in the
	middle of the animation because it continues after zero to fade out the label."""
	$race_shot.play()
	sound_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	yield(get_tree().create_timer(sound_time_delay), "timeout")
	
	for horsie in $objects/horsies.get_children():
		horsie.set_process(true)
	

func _on_lap_completed(horsie):
	self.laps[horsie] += 1
	if self.laps[horsie] >= self.n_laps:
		self.call_deferred("finish_race")


func finish_race():
	globals.is_race_finished = true

	var camera := $camera as Camera2D
	if not camera:
		return

	var rank1_horsies := []
	for horsie in self.ranks:
		var rank = self.ranks[horsie]
		if rank == 1:
			rank1_horsies.append(horsie)
	assert(rank1_horsies.size() > 0)
	var winner = rank1_horsies[globals.rng.randi() % rank1_horsies.size()]
	if globals.is_official_race:
		save_winner(winner)
	winner.z_index = 10 # bring winner to the foreground

	var camera_pos := camera.global_position
	self.remove_child(camera)
	winner.add_child(camera)
	camera.global_position = camera_pos

	Engine.time_scale = 0.05

	var tween: Tween = $utils/tween
	tween.interpolate_property(
		camera, "zoom", camera.zoom, Vector2(0.25, 0.25),
		0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		camera, "position", camera.position, Vector2.ZERO,
		0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)

	var music: AudioStreamPlayer = $utils/music
	tween.interpolate_property(
		music, "pitch_scale", music.pitch_scale, music.pitch_scale-0.5,
		2.5, Tween.TRANS_LINEAR
	)
	tween.interpolate_property(
		music, "volume_db", music.volume_db, music.volume_db-20,
		2.5, Tween.TRANS_LINEAR
	)

	var winner_label: RichTextLabel = $gui/winner
	var text := (
		"[center][shake rate=50 level=30][rainbow]Congratulations[/rainbow]\n"
		+ "[color=#{color}]{name}[/color][/shake][/center]"
	).format({color=winner.tint.to_html(), name=winner.name})
	winner_label.bbcode_text = text
	winner_label.visible_characters = 0
	tween.interpolate_property(
		winner_label, "visible_characters", 0, text.length(),
		0.01 * text.length(), Tween.TRANS_LINEAR
	)
	tween.start()


func _on_turbo_timer_timeout():
	var horsies := $objects/horsies.get_children()
	for h in horsies:
		h.in_turbo = false


func save_winner(winner):
	globals.file_save(globals.WINNERS_FILE, Time.get_date_string_from_system() + " " + str(winner.name))
	





func _on_crowd_area_area_entered(area):
	if area.get_parent().get_parent().name == "horsies":
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property($crowd_area/crowd_sound, "volume_db", -7, 0, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.start()


		for u in $objects/ultras.get_children():
			u.animation.playback_speed = 1.8


func _on_crowd_area_area_exited(area):
	if area.get_parent().get_parent().name == "horsies": 
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property($crowd_area/crowd_sound, "volume_db", 0, -7, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.start()
		for u in $objects/ultras.get_children():
			u.animation.playback_speed = 1
