extends Path2D


var initial_y: float


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


func _process(delta):
	if not initial_y:
		initial_y = global_position.y
	
	for x in $PathFollow2D.get_children():
		x.scale *= global_position.y/initial_y
