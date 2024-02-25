extends Node2D

onready var animation = $AnimationPlayer


func _ready():
	change_animation()
	
#func _process(delta):
#	pass

func set_face(texture):
	$torso/face.texture = texture


func change_animation():
	randomize()
	var animations = animation.get_animation_list()
	var x = randi() % (len(animations) - 1)
	if animations[x] == "flare":
		$torso/arm_left/flare.visible = true
	else:
		$torso/arm_left/flare.visible = false
	animation.play(animations[x])



func _on_AnimationPlayer_animation_finished(anim_name):
	change_animation()
