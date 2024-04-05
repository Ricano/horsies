extends Node2D

onready var animation = $AnimationPlayer
onready var flare = $torso/arm_left/flare
onready var horn = $torso/arm_left/horn

onready var animations = animation.get_animation_list()

var sound_time_delay : float

func _ready():
	
	#drummer only animations
	animations.remove(animations.find("drum"))
	animations.remove(animations.find("walk_loop"))
	animations.remove(animations.find("go_to_hit"))
	animations.remove(animations.find("hit_the_horsie"))
	animations.remove(animations.find("return_to_stands"))
	randomize()
	if randf() < 0.25:
		scale.x = -scale.x

	change_animation()


	
func set_face(texture):
	$torso/face.texture = texture


func change_animation():
	var x = randi() % (len(animations) - 1)
	while animations[x] == "horn" and randf() > 0.1:
		x = randi() % (len(animations) - 1)
		
	handle_animation(animations[x])
	animation.play(animations[x])


func handle_animation(anim):

	if anim == "flare":
		flare.visible = true
		$color_particle.visible=true
	else:
		flare.visible = false
		$color_particle.visible=false
		
	if anim == "horn":
		horn.get_child(0).pitch_scale += randf()*0.1
		horn.get_child(0).play()
		sound_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
		yield(get_tree().create_timer(sound_time_delay), "timeout")
		horn.visible = true
	else:
		horn.visible = false
	$torso/arm_left/hammer.visible=false
	
	
func kapow():
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	change_animation()
