extends Node

# HUD.gd -- this is the `hud` node moved out of Player and into its own scene

# TO DO: define public API for HUD, so that HUD receives 'update_weapon', 'update_health', 'show_message', 'take_damage', etc whenever something changes; the only HUD element that needs to draw itself in [_physics]_process is the radar, as it must track NPCs' independent movements; Q. should we implement this public API as signals? probably: signals allow Inventory to update the HUD by broadcasting weapon/health-change notifications (to invoke HUD methods directly, Inventory would need access to Player.HUD, or HUD._ready would have to bind self to Inventory - tighter coupling that prevents us testing the Inventory without a HUD attached)

# TO DO: move current weapon's ammo readouts onto gun stocks (cf Halo and other modern FPSes); these should look similar to Classic's bitmap/bar ammo readouts (we might make an exception for Magnum and show that as number for space); BTW, this is another reason for using signals for change notification, keeping both HUD and WIH loosely coupled to Inventory

# for Inventory, listing ammo counts as vertical list in top-right corner should be sufficient; we can show all ammo types here, omitting those for which we don't yet have a weapon; that gives user the same ammo information that was displayed in the Classic HUD, using short names so it isn't [too] visually intrusive

# Q. list magazine counts for all [currently carried] weapons on-screen, as in M2? or show current weapon's magazines only and only list all magazines in inventory overlay? if we show all mags on screen, keep it visually low-key, e.g. white lettering with short ammo names (the current weapon's ammo supply can be highlighted in bold)
#
# one argument for always showing *all* ammos on screen is that this is a Classic gameplay feature (albeit a minor one): seeing at a glance how much ammo the player is carrying enables user to judge when to switch guns to preserve a particular ammo type for later, e.g. switching from AR to magnums when AR ammo is running low but pistol ammo is plentiful





# TO DO: decide when/how to draw automap later: redraws would probably be triggered by having Player's _physics_process emit a `player_did_move(...)` signal whenever the player turns or moves (i.e. whenever Player.global_transform changes); Radar could receive the same signal and redraw its center blip



# weapon-in-hand status; this is temporary until visual HUD designs are developed
@onready var weapon_name    := $WeaponStatus/WeaponName
@onready var primary_ammo   := $WeaponStatus/PrimaryAmmo
@onready var secondary_ammo := $WeaponStatus/SecondaryAmmo

# TO DO: undecided on whether or not to support crosshair for easier aiming; excepting rocket launcher (which could have its own aim sight that appears when it is active), all weapons are centrally positioned in view (or equidistant for dual-wield) so targeting even distant bad guys and switches is relatively easy
@onready var crosshair := $Crosshair

# interaction board is for short-lived one-line messages telling player how to interact with a control panel # TO DO: this should probably be centered on screen
@onready var center_notification := $CenterContainer/CenterNotification
@onready var center_animations   := $CenterContainer/AnimationPlayer

# message board is for persistent multi-line messages; mostly useful for listing objectives, netplay kills, debug messages
@onready var message_list := $MessageList





func _ready():
	reset_notification()
	update_weapon()
	crosshair.position = get_viewport().size / 2 # let's assume the viewport size won't change while in-game
	await get_tree().create_timer(2).timeout
	display_notification("Testing HUD notification", 2)
	



func update_health() -> void:
	pass


func update_weapon() -> void:
	var weapon := Inventory.current_weapon
	var trigger1 := weapon.primaryTrigger
	var trigger2 := weapon.secondaryTrigger
	weapon_name.text = weapon.long_name
	# TO DO: triggers' ammo count[s] should appear on gun barrels, c.f. Halo and other modern FPSes - that puts weapon status information near to center of screen (where the user's eye is usually focused) so it's quick and easy to glance at, makes use of what would otherwise be boring wasted screen space (solid gun butts), and just looks plain gosh darn good when playing
	primary_ammo.text = "%s/%s   %02d %s" % [trigger1.count, trigger1.max_count, trigger1.inventory_item.count, trigger1.inventory_item.short_name]
	secondary_ammo.text = "%s/%s   %02d %s" % [trigger2.count, trigger2.max_count, trigger2.inventory_item.count, trigger2.inventory_item.short_name]






func display_notification(message: String, wait_time: float) -> void:
	center_notification.text = message
	center_animations.play("FadeIn")
	await get_tree().create_timer(wait_time).timeout
	center_animations.play("FadeOut")

func reset_notification() -> void:
	center_animations.play("RESET")



#var message_count = 0

func add_message(message, time_left, delete_on_signal = ""): # TO DO: decide API and finish implementation
	var label = Label.new()
	label.set_text(message)
	message_list.add_child(label)
