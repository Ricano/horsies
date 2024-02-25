extends Node2D


func _ready():
	$torso/arm_left/stick.visible=true
	$color_particle.visible = false
	$torso/arm_left/flare.visible=false
	$torso/arm_left/horn.visible=false
	var texture = load("res://ultra/Monteiro.png")
	$torso/face.texture = texture
	$torso/face.scale*=0.6
	$AnimationPlayer.play("walk_loop")
	
	
func _process(delta):
	get_parent().offset+=delta*13.7
	if get_parent().unit_offset == 1:
		$AnimationPlayer.play("drum")
		
		
		


