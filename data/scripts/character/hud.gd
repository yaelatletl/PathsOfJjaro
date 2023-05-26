extends Component

enum BAR_LOCATIONS{
	TOP_CENTER,
	TOP_RIGHT,
	MID_RIGHT,
	BOTTOM_LEFT, 
	BOTTOM_CENTER
}



#@export var weapon_path: NodePath = ""

@export var weapon_hud_ammo_path: NodePath = ""
@export var weapon_hud_clip_path: NodePath = ""
@export var weapon_hud_text_path: NodePath = ""

@export var interact_board_path: NodePath = "Layout/VerticalSections/Top/InteractionBoard"
@export var message_board_path: NodePath = "Layout/VerticalSections/Mid/MessageBoard"

@export var crosshair_path: NodePath = ""

#@onready var weapon = get_node(weapon_path)
@onready var weapon_hud_text = get_node(weapon_hud_text_path)
@onready var weapon_hud_clip = get_node(weapon_hud_clip_path)
@onready var crosshair = get_node(crosshair_path)

@onready var weapon_hud_ammo = get_node(weapon_hud_ammo_path)
@onready var interact_board = get_node(interact_board_path)
@onready var message_board = get_node(message_board_path)


func _ready():
	_component_name = "HUD"

func _process(_delta) -> void:
	_weapon_hud()
	#_crosshair()

func register_progress_bar(location, name, value, min_value, max_value):
	#TODO: What's the point of this?
	pass

func _weapon_hud() -> void:
	#var unchecked = Vector2(180, 80)
	#weapon_hud.position = get_viewport().size - unchecked
	var weapons_node = actor._get_component("weapons")
	if not weapons_node:
		return
	
	weapon_hud_text.text = str(weapons_node.arsenal.values()[weapons_node.current].gun_name)
	weapon_hud_clip.text = str(weapons_node.arsenal.values()[weapons_node.current].bullets)
	weapon_hud_ammo.text = str(weapons_node.arsenal.values()[weapons_node.current].ammo)
	
	# Color
	if weapons_node.arsenal.values()[weapons_node.current].bullets < (weapons_node.arsenal.values()[weapons_node.current].max_bullets/4):
		weapon_hud_ammo.add_theme_color_override("font_color", Color("#ff0000"))
	elif weapons_node.arsenal.values()[weapons_node.current].bullets < (weapons_node.arsenal.values()[weapons_node.current].max_bullets/2):
		weapon_hud_clip.add_theme_color_override("font_color", Color("#dd761b"))
	else:
		weapon_hud_clip.add_theme_color_override("font_color", Color("#ffffff"))

func _crosshair() -> void:
	crosshair.position = get_viewport().size/2
