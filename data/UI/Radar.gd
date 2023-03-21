@tool
extends ColorRect

@export var actor_path: NodePath = ""
@export var background: Color = Color.ALICE_BLUE
@export var border: Color = Color.BLACK
@export var border_resolution: int = 360
@export var border_width: int = 1

@export var health: float = 100
@export var max_health: float = 100
@export var health_color: Color = Color.BLACK
@export var shields: float = 50
@export var max_shields: float = 100
@export var shield_color: Color = Color.BLACK

@onready var actor = get_node(actor_path)

func _ready():
	actor.connect("health_changed",Callable(self,"_on_health_changed"))

func _on_health_changed(health_in: float, shields_in: float):
	health = health_in
	shields = shields_in

func _process(delta):
	#TODO: fix this update()
	pass


func _draw():
	draw_circle(size/2, min(size.x/3, size.y/3), background)
	draw_arc (size/2, min(size.x/3, size.y/3), 0, deg_to_rad(360), border_resolution, border, border_width, true)
	if health > 0:
		draw_arc (size/2, min(size.x/3, size.y/3), 0, deg_to_rad(health/max_health*180), border_resolution, health_color, border_width, true)
	if shields > 0:
		draw_arc (size/2, min(size.x/3, size.y/3), deg_to_rad(180), deg_to_rad(180+180*shields/max_shields), border_resolution, shield_color, border_width, true)
