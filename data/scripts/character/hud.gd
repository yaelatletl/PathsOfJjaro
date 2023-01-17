extends Component

enum BAR_LOCATIONS{
	TOP_CENTER,
	TOP_RIGHT,
	MID_RIGHT,
	BOTTOM_LEFT, 
	BOTTOM_CENTER
}



export(NodePath) var weapon
export(NodePath) var weapon_hud_ammo
export(NodePath) var weapon_hud_clip
export(NodePath) var weapon_hud_text

export(NodePath) var interact_board_path = "Layout/VerticalSections/Top/InteractionBoard"
export(NodePath) var message_board_path = "Layout/VerticalSections/Mid/MessageBoard"

export(NodePath) var crosshair
onready var interact_board = get_node(interact_board_path)
onready var message_board = get_node(message_board_path)


func _ready():
	_component_name = "HUD"
	weapon = get_node(weapon)
	weapon_hud_ammo = get_node(weapon_hud_ammo)
	weapon_hud_clip = get_node(weapon_hud_clip)
	weapon_hud_text = get_node(weapon_hud_text)
	crosshair = get_node(crosshair)

func _process(_delta) -> void:
	_weapon_hud()
	#_crosshair()

func register_progress_bar(location, name, value, min_value, max_value):
	pass

func _weapon_hud() -> void:
	#var off = Vector2(180, 80)
	#weapon_hud.position = get_viewport().size - off
	
	weapon_hud_text.text = str(weapon.arsenal.values()[weapon.current].gun_name)
	weapon_hud_clip.text = str(weapon.arsenal.values()[weapon.current].bullets)
	weapon_hud_ammo.text = str(weapon.arsenal.values()[weapon.current].ammo)
	
	# Color
	if weapon.arsenal.values()[weapon.current].bullets < (weapon.arsenal.values()[weapon.current].max_bullets/4):
		weapon_hud_ammo.add_color_override("font_color", Color("#ff0000"))
	elif weapon.arsenal.values()[weapon.current].bullets < (weapon.arsenal.values()[weapon.current].max_bullets/2):
		weapon_hud_clip.add_color_override("font_color", Color("#dd761b"))
	else:
		weapon_hud_clip.add_color_override("font_color", Color("#ffffff"))

func _crosshair() -> void:
	crosshair.position = get_viewport().size/2
