tool
extends Control

export(Color) var full = Color.aliceblue
export(Color) var empty = Color.black
export(int) var border_resolution = 360
export(int) var border_width = 1
export(int) var offset = 0
export(float) var value = 0
export(float) var value_max = 100
export(bool) var fills = true
var current_color = Color.white
func _ready():
	#rect_size = get_parent().rect_size
	current_color = full

func _process(delta):
	update()
	if fills:
		current_color = lerp(empty, full, value / value_max)
	else:
		current_color = lerp(full, empty, value / value_max)
func _draw():
	#draw_circle(rect_size/2, min(rect_size.x/3, rect_size.y/3), background)
	var res_end = clamp(4 + (value/value_max * 360), 4, 360)
	if not fills and value > 0.1:
		res_end = clamp(4 + (value_max/value * 360), 4, 360)
	draw_arc (rect_size/2, min(rect_size.x/3, rect_size.y/3)+offset, 0, deg2rad(res_end), res_end, current_color, border_width, true)

