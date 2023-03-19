@tool
extends Control

@export var full: Color = Color.ALICE_BLUE
@export var empty: Color = Color.BLACK
@export var border_resolution: int = 360
@export var border_width: int = 1
@export var offset: int = 0
@export var value: float = 0
@export var value_max: float = 100
@export var fills: bool = true
var current_color = Color.WHITE
func _ready():
	#size = get_parent().size
	current_color = full

func _process(delta):
	update()
	if fills:
		current_color = lerp(empty, full, value / value_max)
	else:
		current_color = lerp(full, empty, value / value_max)
func _draw():
	#draw_circle(size/2, min(size.x/3, size.y/3), background)
	var res_end = clamp(4 + (value/value_max * 360), 4, 360)
	if not fills and value > 0.1:
		res_end = clamp(4 + (value_max/value * 360), 4, 360)
	draw_arc (size/2, min(size.x/3, size.y/3)+offset, 0, deg_to_rad(res_end), res_end, current_color, border_width, true)

