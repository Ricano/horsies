extends Node2D

var horsie_to_hit: Node2D
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
	if not horsie_to_hit and not horsie.in_turbo:
		horsie_to_hit = horsie
		hit_horsie(horsie)
		

func hit_horsie(horsie: Node2D):
	horsie_to_hit = horsie
	$AnimationPlayer.play("hit_the_horsie")


	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit_the_horsie":
		$AnimationPlayer.play("return_to_stands")
	if anim_name == "return_to_stands":
		$AnimationPlayer.play("drum")
	
	
func kapow():
	horsie_to_hit.anim.play("stun")
	yield(get_tree().create_timer(hitted_horsie_stun_time), "timeout")
	horsie_to_hit = null
