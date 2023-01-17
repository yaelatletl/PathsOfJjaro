tool
extends ColorRect

export(NodePath) var actor_path = ""
export(Color) var background = Color.aliceblue
export(Color) var border = Color.black
export(int) var border_resolution = 360
export(int) var border_width = 1

export(float) var health = 100
export(float) var max_health = 100
export(Color) var health_color = Color.black
export(float) var shields = 50
export(float) var max_shields = 100
export(Color) var shield_color = Color.black

onready var actor = get_node(actor_path)

func _ready():
	actor.connect("health_changed", self, "_on_health_changed")

func _on_health_changed(health_in: float, shields_in: float):
	health = health_in
	shields = shields_in

func _process(delta):
	update()

func _draw():
	draw_circle(rect_size/2, min(rect_size.x/3, rect_size.y/3), background)
	draw_arc (rect_size/2, min(rect_size.x/3, rect_size.y/3), 0, deg2rad(360), border_resolution, border, border_width, true)
	if health > 0:
		draw_arc (rect_size/2, min(rect_size.x/3, rect_size.y/3), 0, deg2rad(health/max_health*180), border_resolution, health_color, border_width, true)
	if shields > 0:
		draw_arc (rect_size/2, min(rect_size.x/3, rect_size.y/3), deg2rad(180), deg2rad(180+180*shields/max_shields), border_resolution, shield_color, border_width, true)
