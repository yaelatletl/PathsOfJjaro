extends Control


# CircularMeter.gd -- unused

# TO DO: let's use the radar border to indicate Repair level objective[s] (switch hunts are really tiresome without some help finding them: we'll put the switch locations, which have been already shown in the terminal, in the automap, and put dots around the radar which rotate around ring as player turns so they always point to where those switches are: red/orange for TODO, green/blue for DONE - keep the completed switches visible as when there are 2+ they also help user triangulate player's location)


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
	#TODO: fix update()
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

