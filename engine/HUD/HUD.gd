extends Node

# HUD.gd -- this is the `hud` node moved out of Player and into its own scene

# TO DO: move bullets_remaining readouts onto gun stocks? (cf Halo and other modern FPSes); show number of remaining magazines in top-right is sufficient; 

# Q. list magazine counts for all [currently carried] weapons on-screen, as in M2? or show current weapon's magazines only and only list all magazines in inventory overlay? if we show all mags on screen, keep it visually low-key, e.g. white lettering with short ammo names (the current weapon's ammo supply can be highlighted in bold)

# one argument for always showing all ammos on screen is that this is a Classic gameplay feature (albeit a minor one): seeing at a glance how much ammo the player is carrying enables user to judge when to switch guns to preserve a particular ammo type for later, e.g. switching from AR to magnums when AR ammo is running low but pistol ammo is plentiful


# TO DO: HUD 2D uses lots of box/alignment containers; are these really necessary? it should be sufficient to position visible nodes relative to edges/corners; HBox/VBox containers should only be needed when several elements form a vertical/horizontal list


#@onready var weapon = get_node(weapon_path)
@onready var weapon_hud_text = $VerticalSections/Bottom/Weapons/name
@onready var magazine_count = $VerticalSections/Bottom/Weapons/Ammo/ammo
@onready var bullets_remaining = $VerticalSections/Bottom/Weapons/Ammo/bullets

@onready var crosshair = $VerticalSections/Mid/crosshair

# interaction board is for short-lived one-line messages telling player how to interact with a control panel # TO DO: this should probably be centered on screen
@onready var interact_board = $VerticalSections/Top/InteractionBoard

# message board is for persistent multi-line messages; mostly useful for listing objectives, netplay kills, debug messages
@onready var message_board = $VerticalSections/Mid/MessageBoard


func _ready():
	pass
	# crosshair.position = get_viewport().size / 2 # TO DO: assuming we keep crosshair, its position only needs set when game is entered or user adjusts viewport size (resizing window/changing resolution)

#func _process(_delta) -> void:
#	_weapon_hud()

func register_progress_bar(location, name, value, min_value, max_value):
	#TODO: What's the point of this?
	pass

func _weapon_hud() -> void:
	
	return
	#var unchecked = Vector2(180, 80)
	#weapon_hud.position = get_viewport().size - unchecked
	var weapons_node = null #actor._get_component("weapons")
	if not weapons_node:
		return
	
	weapon_hud_text.text = str(weapons_node.arsenal.values()[weapons_node.current].gun_name)
	bullets_remaining.text = str(weapons_node.arsenal.values()[weapons_node.current].bullets)
	magazine_count.text = str(weapons_node.arsenal.values()[weapons_node.current].ammo)
	
	# Color
	if weapons_node.arsenal.values()[weapons_node.current].bullets < (weapons_node.arsenal.values()[weapons_node.current].max_bullets/4):
		bullets_remaining.add_theme_color_override("font_color", Color("#ff0000"))
	elif weapons_node.arsenal.values()[weapons_node.current].bullets < (weapons_node.arsenal.values()[weapons_node.current].max_bullets/2):
		magazine_count.add_theme_color_override("font_color", Color("#dd761b"))
	else:
		magazine_count.add_theme_color_override("font_color", Color("#ffffff"))

