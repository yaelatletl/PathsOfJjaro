extends Node3D
class_name WeaponInHand


# weapons/WeaponInHand.gd -- abstract base class for single-wield weapon with single/dual-function trigger[s]

# TO DO: move these reusable base classes to engine/weapons?


# note: WiH assumes Weapon enforces all trigger interlocks and delays, and will only enit valid signals


# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)

# TO DO: for animating bobbing motions as player moves, define either a `move(gait)` method or separate stop+walk+sprint+crouch+swim methods



# TO DO: while WiH animations could send `animation_ended` notifications back to Weapon, we probably want to avoid that coupling and rely solely on the timings specified in the weapon_definition to trigger Weapon's state machine transitions (this means a weapon animation might be interrupted by a new animation, causing it to glitch visually; however, that is much less evil than tying weapon behavior to animations which would cause all sorts of timing problems in the engine)


#var asset_id: int:
#	get:
#		return Enums.make_asset_id(asset_type, weapon_type)


#var asset_type  := Enums.AssetType.WEAPON_IN_HAND
var weapon_type: Enums.WeaponType



var primary_hand: Node3D
var primary_animation: AnimationPlayer
var is_primary_available := false

var secondary_hand: Node3D # for single-wield weapons this should be same as primary
var secondary_animation: AnimationPlayer # ditto, except where firing modes are independent (AR) in which case the secondary trigger's shoot and reload animation player
var is_secondary_available := false

var dual_offset_x: float


# TO DO: decide how best to manage sounds; it'd be nice not to have dozens of audio nodes! probably best to put 
@onready var audio_activate         := $Audio/Activate
@onready var audio_shoot_primary    := $Audio/ShootPrimary
@onready var audio_shoot_secondary  := $Audio/ShootSecondary
@onready var audio_reload_primary   := $Audio/ReloadPrimary
@onready var audio_reload_secondary := $Audio/ReloadSecondary
@onready var audio_empty            := $Audio/Empty


var is_connected_to_current_weapon := false


func _ready() -> void:
	pass


# IMPORTANT: each WIH must implement a _ready function that calls this
# TO DO: this API is NOT final; once the remaining weapons are added, we can decide how best to map single-wield single-trigger, single-wield dual-trigger/mode, and dual-wield
func initialize(weapon_type: Enums.WeaponType, 
				primary_hand: Node3D, primary_animation: AnimationPlayer, 
				secondary_hand: Node3D, secondary_animation: AnimationPlayer, dual_offset_x: float = 0) -> void:
	self.weapon_type = weapon_type
	self.primary_hand       = primary_hand
	self.primary_animation   = primary_animation
	self.secondary_hand     = secondary_hand
	self.secondary_animation = secondary_animation
	self.dual_offset_x       = dual_offset_x
	self.visible = false
	self.reset()
	WeaponManager.add_weapon_in_hand(self)
	print("initialized WeaponInHand: ", self.weapon_type)


# in dual-wield weapons, either or both hands may hold guns, depending on how many guns are in Inventory and whether they contain rounds (or can be reloaded) or not

func update_trigger_availability(is_primary_available: bool, is_secondary_available: bool) -> void: # for single-wield weapons, this only sets the flags; that being said, WIH subclasses could override to perform animations if needed
	self.is_primary_available = is_primary_available
	self.is_secondary_available = is_secondary_available


func play_animation(track: String) -> void:
	self.primary_animation.play(track)
	print(self.name, ": animate: ", track)


# Weapon signal handlers

func activating(weapon: Weapon) -> void: # called by Weapon when Player activates it
	self.visible = true # this hides the entire WIH node when it's unused and out of sight, which is separate to hiding primary/secondary hand when only 1 is in use
	self.update_trigger_availability(weapon.primary_trigger.available, weapon.secondary_trigger.available)
	print("ACTIVATING ", self.name, "  ", self.visible)
	self.play_animation("activate")
	audio_activate.play()


func activated(weapon: Weapon) -> void: # called by Weapon when Player activates it
	self.visible = true
	print("ACTIVATED ", self.name)
	self.update_trigger_availability(weapon.primary_trigger.available, weapon.secondary_trigger.available)
	self.idle()
	

func deactivating(weapon: Weapon) -> void: # called by Weapon when Player deactivates it
	# TO DO: fix the `swap_out` animation so that it starts with single pistol in its idle position and ends with nothing visible on screen
	# TO DO:  remove 4.4sec of dead time from animation (the swap in/out animations should be around 1sec)
	print("DEACTIVATING ", self.name)
	self.play_animation("deactivate")

func deactivated(weapon: Weapon) -> void:
	self.visible = false
	print("DEACTIVATED ", self.name)


# TO DO: how best to implement magazine displays?

func update_primary_magazine_display(magazine: WeaponTrigger.Magazine) -> void:
	pass

func update_secondary_magazine_display(magazine: WeaponTrigger.Magazine) -> void:
	pass


# weapon states

func reset() -> void: # weapon is doing nothing and is out of sight (below camera)
	self.play_animation("RESET")
	

func idle() -> void: # weapon is doing nothing
	self.play_animation("idle")


func shoot_primary(weapon: Weapon, successfully: bool) -> void:
	if successfully:
		self.play_animation("primary_shoot")
		audio_shoot_primary.play()
	else:
		audio_empty.play()

func shoot_secondary(weapon: Weapon, successfully: bool) -> void:
	if successfully:
		self.play_animation("secondary_shoot")
		audio_shoot_secondary.play()
	else:
		audio_empty.play()


func reload_primary(weapon: Weapon, successfully: bool) -> void:
	self.update_trigger_availability(weapon.primary_trigger.available, weapon.secondary_trigger.available)
	if successfully:
		self.play_animation("primary_reload")
		audio_reload_primary.play()

func reload_secondary(weapon: Weapon, successfully: bool) -> void:
	self.update_trigger_availability(weapon.primary_trigger.available, weapon.secondary_trigger.available)
	if successfully:
		self.play_animation("secondary_reload")
		audio_reload_secondary.play()


# fusion pistol only

func charging() -> void:
	pass

func charged() -> void:
	pass

func explode() -> void:
	pass

