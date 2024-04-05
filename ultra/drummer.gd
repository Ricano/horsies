extends Node2D

var horsie_to_hit: Node2D
var horsie_to_hit_list:= []

var hitted_horsie_stun_time:= 3

func _ready():
	$drum.visible = true
	$torso/arm_left/stick.visible=true
	$color_particle.visible = false
	$torso/arm_left/flare.visible=false
	$torso/arm_left/hammer.visible=false
	$torso/arm_left/horn.visible=false
	var texture = load("res://ultra/Monteiro.png")
	$torso/face.texture = texture
	$torso/face.scale*=0.6
	$AnimationPlayer.play("walk_loop")
	
	
func _process(delta):
	get_parent().offset+=delta*12
	if get_parent().unit_offset == 1:
		$AnimationPlayer.play("drum")
		set_process(false)


func _on_drummer_action_area_area_entered(area):
	var horsie = area.get_parent()
	var racing_horsies_number = len(globals.horsies)
	
	var x = int(racing_horsies_number/3.0)+1
	
	printerr(racing_horsies_number, ">>", x)
	if len(horsie_to_hit_list) < x:
		horsie_to_hit_list.append(horsie)
		printerr(horsie, "has been added to hit_list")
		
	else:
		if not horsie_to_hit:
			horsie_to_hit_list.shuffle()
			printerr("Shuffled list:", horsie_to_hit_list)
			for h in horsie_to_hit_list:
				if not horsie.in_turbo:
					horsie_to_hit = horsie_to_hit_list[0]
					printerr("Horsie to hit:", horsie_to_hit.name)
					$AnimationPlayer.play("go_to_hit")
					break


func _on_hit_area_area_entered(area):
	if area.get_parent() == horsie_to_hit:
		$AnimationPlayer.stop()
		hit_horsie(horsie_to_hit)


func hit_horsie(horsie: Node2D):
	$torso/arm_left/hammer/AudioStreamPlayer2D.play()
	var sound_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	yield(get_tree().create_timer(sound_time_delay*2/3), "timeout")
	$AnimationPlayer.play("hit_the_horsie")



	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit_the_horsie":
		$AnimationPlayer.play("return_to_stands")
	if anim_name == "return_to_stands":
		$AnimationPlayer.play("drum")
	

func kapow():
	horsie_to_hit.get_stunned()
	yield(get_tree().create_timer(hitted_horsie_stun_time), "timeout")
	horsie_to_hit_list.clear()
	printerr("Hit list was cleared.")
	horsie_to_hit = null
	printerr("Horsie to hit is None")
	
