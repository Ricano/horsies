extends Node2D
class_name Horsie

signal lap_completed()

const MIN_SPEED := 40.0
const MAX_SPEED := 60.0
const TURBO_MULTIPLIER = 1.618

export var tint := Color.white
export var turbo_probability := 0.003

var speed := 50.0  # pixels/second
var acceleration := 5.0  # pixels/second^2
var rank := 1

var horsie_ketchup_multiplier := 1.0
var horsie_speed_variation := 1.0
var is_last := false
var in_turbo := false
onready var turbo_sounds = $turbo_sounds.get_children()
onready var turbo_timer = get_node("/root/world/turbo_timer")
onready var follow: PathFollow2D = $follow
onready var anim = $anim
onready var sky_rocket_sound = $sky_rocket_sound


var sound_time_delay : float


func _ready():
	yield(get_tree().create_timer(randf()), "timeout")
	anim.play("ready")
	if globals.turbo_mode:
		add_face()
		pump_the_horsie()

	$sprite.self_modulate = self.tint
	self.follow.get_node("remote_transform").remote_path = self.get_path()


func _process(delta: float):
		var previous_unit_offset := self.follow.unit_offset
		var ketchup := 0.1 * (1.0 - 1.0 / self.rank)
		var dspeed := (globals.rng.randf_range(-horsie_speed_variation, horsie_speed_variation) + ketchup*horsie_ketchup_multiplier) * self.acceleration * delta
		self.speed = clamp(self.speed + dspeed, MIN_SPEED, MAX_SPEED)
		if can_go_turbo():
			speed*=TURBO_MULTIPLIER
		if not in_turbo:
			$sprite/turbo_flames.hide()
			
		self.follow.offset += self.speed * delta
		if self.follow.unit_offset < previous_unit_offset and not globals.is_race_finished:
			self.emit_signal("lap_completed")
		anim.playback_speed = self.speed/MAX_SPEED


func sky_rocket():
	var x = randf()
	if x < 0.05:
		sky_rocket_sound.play()
		sound_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
		yield(get_tree().create_timer(sound_time_delay), "timeout")
		anim.stop()
		anim.play("sky_rocket")


func setup(track: Path2D, lane: int):
	print("Setting up horsie {0} on lane {1}".format([self.get_path(), lane]))
	self.remove_child(self.follow)
	track.add_child(self.follow)
	self.follow.v_offset = lane * 2


func add_face():
	if self.name == "Rei":
		return
	
	var face_texture = load("res://horsie/faces/" + str(self.name) + ".png")
	$sprite/face.texture = face_texture
	if self.name == "Fátima": # her face is quite long :)
		$sprite/face.offset = Vector2(4, -48)


func pump_the_horsie():
	horsie_ketchup_multiplier = 5.0
	horsie_speed_variation = 20.0


func can_go_turbo():
	if globals.turbo_mode and $turbo_start_timer.is_stopped(): # wait till the end of the song's intro to start turboing...
		if is_last and turbo_timer.is_stopped() and globals.rng.randf() < turbo_probability:
			in_turbo = true
			turbo_sounds[globals.rng.randi_range(0,4)].play()
			# apparently there's an issue with sound lagging on play in linux
			# due to the pulseaudio lib ¯\_(ツ)_/¯
			# this added 'sound_time_delay' is a shitty workaround, but makes
			# the fart sounds play when they should \o/
			sound_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
			yield(get_tree().create_timer(sound_time_delay), "timeout")
			turbo_timer.start()
			$sprite/turbo_flames.show()
			return true
		elif not turbo_timer.is_stopped() and in_turbo:
			return true


func stop_process():
	set_process(false)


func get_stunned():
	$stun_smoke.visible = true
	$stun_smoke.playing = true
	anim.play("stun")


func _on_anim_animation_finished(anim_name):
	if anim_name == "stun":
		$stun_smoke.visible = false
		$stun_smoke.frame = 0
		
		anim.play("run")
		set_process(true)


func fill_screen_with_face():
	anim.play("fill_screen_with_face")
