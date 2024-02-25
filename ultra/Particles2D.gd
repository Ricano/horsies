extends Particles2D



onready var target = get_parent().get_node("torso/arm_left/flare/smoke_pos")

func _process(delta):
	self.global_position = target.global_position
	
