extends Node

# HUD.gd -- this is the `hud` node moved out of Player and into its own scene

# TO DO: define public API for HUD, so that HUD receives 'update_weapon', 'update_health', 'show_message', 'take_damage', etc whenever something changes; the only HUD element that needs to draw itself in [_physics]_process is the radar, as it must track NPCs' independent movements; Q. should we implement this public API as signals? probably: signals allow InventoryManager to update the HUD by broadcasting weapon/health-change notifications (to invoke HUD methods directly, InventoryManager would need access to Player.HUD, or HUD._ready would have to bind self to InventoryManager - tighter coupling that prevents us testing the InventoryManager without a HUD attached)

# TO DO: move current weapon's ammo readouts onto gun stocks (cf Halo and other modern FPSes); these should look similar to Classic's bitmap/bar ammo readouts (we might make an exception for Magnum and show that as number for space); BTW, this is another reason for using signals for change notification, keeping both HUD and WIH loosely coupled to InventoryManager

# for InventoryManager, listing ammo counts as a vertical list in top-right corner should be sufficient; we can show all ammo types here, omitting those for which we don't yet have a weapon; that gives user the same ammo information that was displayed in the Classic HUD, using short names so it isn't [too] visually intrusive

# Q. list magazine counts for all [currently carried] weapons on-screen, as in M2? or show current weapon's magazines only and only list all magazines in inventory overlay? if we show all mags on screen, keep it visually low-key, e.g. white lettering with short ammo names (the current weapon's ammo supply can be highlighted in bold)
#
# one argument for always showing *all* ammos on screen is that this is a Classic gameplay feature (albeit a minor one): seeing at a glance how much ammo the player is carrying enables user to judge when to switch guns to preserve a particular ammo type for later, e.g. switching from AR to magnums when AR ammo is running low but pistol ammo is plentiful


# note: M3 solo campaign should use different HUD designs to indicate SO's current allegiance (if Classic-style recording is implemented, M3 maps could also have a bit of fun inserting the player's earlier 'ghosts' when revisiting a level)


# TO DO: decide when/how to draw automap later: redraws would probably be triggered by having Player's _physics_process emit a `player_did_move(...)` signal whenever the player turns or moves (i.e. whenever Player.global_transform changes); Radar could receive the same signal and redraw its center blip


func set_movement_text(msg: String) -> void:
	$Movement.text = msg

func set_speed_text(msg: String) -> void:
	$Speed.text = msg


@onready var health := $Health

# weapon-in-hand status; this is temporary until visual HUD designs are developed
@onready var weapon_name    := $WeaponStatus/WeaponName
@onready var primary_ammo   := $WeaponStatus/PrimaryAmmo
@onready var secondary_ammo := $WeaponStatus/SecondaryAmmo

# TO DO: undecided on whether or not to support crosshair for easier aiming; excepting rocket launcher (which could have its own aim sight that appears when it is active), all weapons are centrally positioned in view (or equidistant for dual-wield) so targeting even distant bad guys and switches is relatively easy
@onready var crosshair := $CenterDisplay/Crosshair

# interaction board is for short-lived one-line messages telling player how to interact with a control panel # TO DO: this should probably be centered on screen
@onready var center_notification := $CenterDisplay/Notification/Message
@onready var center_animations   := $CenterDisplay/Notification/AnimationPlayer

# message board is for persistent multi-line messages; mostly useful for listing objectives, netplay kills, debug messages
# TO DO: every time a Bob dies or is captured anywhere on level, display that Bob's name in the message list, e.g. "DuJour, R (DEC)", "Zartman, B (MIA)"; MADDs could also send their own status chatter - all very cheap to implement (compiling the complete list of names will take longer than coding it!) and adds a bit of color, especially on Rescue levels (adds gravitas to Leela's instruction to save all the Bobs when you see them decimating; and it'll make MADDs feel more like a marshall's deputies than independent agents - plus rogue MADDs can send their own unhinged messages too)
@onready var message_list := $MessageList



func _ready():
	reset_notification()
	redraw_current_weapon_status()
	update_health_status()
	# TO DO: is there any way to set up signal connections in the node editor? oddly, the HUD's Scene tab doesn't allow InventoryManager.tscn to be added via Add Child Node, although it does allow it to be dragged and dropped from the FileSystem tab - but does this create a separate instance of it or reference the existing global instance? need to check Godot documentation; not sure if it'd be easier setting these signals in the Node tab than in code, but for now just stick to doing it in code (that this code is visibly ugly suggests the current API design is badly factored):
	
	# note: in addition to updating the HUD display these signals will also drive the WIH animation (but connecting signals to that is the WIH manager's job)
	# TO DO: combine these signals into one? HUD would call WeaponManager.current_weapon.status to discover which transition it's in; an additional caveat is dual-wield weapons, where one gun is activating/deactivating while the other is active
	WeaponManager.weapon_activity_changed.connect(__weapon_status_changed)
	WeaponManager.weapon_magazines_changed.connect(__weapon_status_changed)
	
	InventoryManager.inventory_increased.connect(__inventory_status_changed)
	InventoryManager.inventory_decreased.connect(__inventory_status_changed)
	
	Global.health_changed.connect(update_health_status)
	Global.player_died.connect(update_health_status)
	
	crosshair.position = get_viewport().size / 2 - Vector2i(crosshair.size / 2) # let's assume the viewport size won't change while in-game
	self.visible = true # set to false when player dies
	
	# test
	await get_tree().create_timer(2).timeout
	display_notification("Testing HUD notification", 2)



func player_died(_damage_type: Enums.DamageType) -> void:
	self.visible = false

func player_revived() -> void:
	self.visible = true
	update_health_status()
	redraw_current_weapon_status()
	reset_notification()


func update_health_status(damage_type: Enums.DamageType = Enums.DamageType.NONE) -> void:
	health.text = "SHIELDS: %03d\nOXYGEN: %03d" % [InventoryManager.health, InventoryManager.oxygen]
	if damage_type != Enums.DamageType.NONE:
		pass # TO DO: damage effect animations, e.g. red ColorRect "pain" pulse animation when struck by projectile; jagged blue-white jittery "shock" shader effect when hit by an energy bolt


# TO DO:  it's possible for weapon activating animation to be reversed if the user presses previous/next_weapon key multiple times (repeatedly pressing the key quickly will step over weapons without activating any except the last-selected weapon, but pressing it a bit more slowly may cause a weapon's activating animation to start playing without allowing time for it to finish; ideally there should be a single animation that can be played either forward or backward or slowed/paused at any point so it's trivially reversible, otherwise we'll have to interpolate the model between 2 different positions, which may or may not produce a satisfactory animation)

func __inventory_status_changed(_item: InventoryManager.InventoryItem) -> void:
	redraw_current_weapon_status()
	# TO DO: implement list of all available ammos down right side of screen

func __weapon_status_changed(_weapon: Weapon) -> void: # TO DO: what should weapon signals pass as arguments, if anything? it may be best to pass nothing, leaving listeners to retrieve whatever they need from WeaponManager
	redraw_current_weapon_status()


func redraw_current_weapon_status() -> void:
	var weapon: Weapon = WeaponManager.current_weapon
	if not weapon: return # TO DO: kludgy; WeaponManager.current_weapon should be set before HUD loads
	#print("   ...update weapon status: ", weapon.long_name)
	weapon_name.text = weapon.long_name
	var magazine_1  := weapon.primary_magazine
	var magazine_2  := weapon.secondary_magazine
	var inventory_1 := magazine_1.inventory_item
	var inventory_2 := magazine_2.inventory_item
	# TO DO: triggers' ammo count[s] should appear on gun barrels, c.f. Halo and other modern FPSes - that puts weapon status information near to center of screen (where the user's eye is usually focused) so it's quick and easy to glance at, makes use of what would otherwise be boring wasted screen space (solid gun butts), and just looks plain gosh darn good when playing
	primary_ammo.text = "%s/%s   %02d/%02d %s" % [magazine_1.count, magazine_1.max_count, inventory_1.count, inventory_1.max_count, inventory_1.short_name]
	secondary_ammo.text = "%s/%s   %02d/%02d %s" % [magazine_2.count, magazine_2.max_count, inventory_2.count, inventory_2.max_count, inventory_2.short_name]


# center screen message

func display_notification(message: String, wait_time: float) -> void:
	center_notification.text = message
	center_animations.play("FadeIn")
	await get_tree().create_timer(wait_time).timeout
	center_animations.play("FadeOut")

func reset_notification() -> void:
	center_animations.play("RESET")


# left screen message log

#var message_count = 0

func add_message(message, time_left, delete_on_signal = ""): # TO DO: decide API and finish implementation
	var label = Label.new()
	label.set_text(message)
	message_list.add_child(label)
