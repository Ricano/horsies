extends Sprite

onready var particles = get_parent().get_parent().get_parent().get_node("color_particle")

var colors = [Color.red, Color.blue, Color.yellow, Color.green]



func _ready():
	randomize()
	var x = randi() % len(colors)
	particles.modulate = colors[x]

