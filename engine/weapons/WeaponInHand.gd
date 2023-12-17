class_name WeaponInHand extends Node3D


# weapons/WeaponInHand.gd -- abstract base class for a View class that animates the Player's hand[s] holding a gun; see assets/weapons/NAME/NAME.tscn


# important: each WIH subclass MUST define a WEAPON_TYPE constant, e.g.:
#
# const WEAPON_TYPE := Enums.WeaponType.FIST
#
# WEAPON_TYPE is used to attach WIH views, which are [currently] part of each level's scene tree, to their Weapon, which is managed by global WeaponManager and persists across levels (this arrangement will likely change in future, but it will do for Arrival Demo)



# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)


# TO DO: define a WeaponInHand.Placeholder class which implements all WIH methods but emits print and/or HUD messages only (it won't have animations or sounds so can be RefCounted); use this placeholder scene as the initial value of Weapon's __primary_hand and __secondary_hand properties; this will allow Weapon to be tested with or without view scenes attached (using Weapon without its required WIH[s] currently raises an exception)


# TO DO: how best to animate weapon-in-hand bob when Player walks/runs/crawls/jumps/climbs, etc? these might be implemented on Player, using parameters from PlayerDefinitions to customize bob height, sway, etc; alternatively, they might be implemented as WIH methods which Player calls
#
# similarly, if we use hand gestures to indicate when an Action can be performed (e.g. player is looking at a switch), should the WIH be responsible for animating that hand gesture or should there be separate hand animation scenes?
#
# I think for now we don't worry too much about this: let's get the "dumb" 1990s-era WIHs working first, where gun[s] are *always* visible on screen (MVP for Arrival Demo), and we can decide if/how to pretty up individual hand animations later



enum Hand { # used for dual-wield weapons
	PRIMARY,
	SECONDARY,
}

@export var hand := Hand.PRIMARY

@onready var model     := $Weapon
@onready var animation := $Animation


# TO DO: consider attaching magazines to WIH via configure() call, allowing animation methods below to update diegetic ammo displays themselves (currently Weapons must call update_ammo, which is clumsy)


func _ready() -> void:
	model.visible = false
	self.reset()
	WeaponManager.connect_weapon_in_hand(self) # WeaponInHand scenes attached to Player call this when Player is instantiated
	#print("WeaponInHand._ready for: ", self.name)


# called by Weapon

func activating() -> void:
	model.visible = true
	animation.play("activate")

func activated() -> void: # called by Weapon when Player activates it
	model.visible = true
	self.idle()

func deactivating() -> void: # called by Weapon when Player deactivates it
	animation.play("deactivate")

func deactivated() -> void:
	model.visible = false


# TO DO: how best to implement magazine displays?

func update_ammo(primary_magazine: Weapon.Magazine, secondary_magazine: Weapon.Magazine) -> void:
	pass


# weapon states

func reset() -> void: # weapon is doing nothing and is out of sight (below camera)
	animation.play("RESET")

func idle() -> void: # weapon is doing nothing
	animation.play("idle")

# TO DO: do not pass successfully; define emptied method instead
func shoot() -> void:
	animation.play("shoot")

func empty() -> void:
	animation.play("empty")

func reload() -> void:
	animation.play("reload")


# TO DO: alternative approach is to build the single-gun reload as one animation, since the other hand is already hidden

func reload_other() -> void: # dual-wield weapons where both hands must interact to reload one gun while holding magazine (and possibly another gun) in the other hand
	# note: only used by pistols (fists never reload, shotguns reload one-handed, and single-wield weapons use a single model which can animate one or two hands)
	animation.play("reload_other_hand_while_holding_weapon" if model.visible else "reload_other_hand")


# single-wield WIH subclasses (fusion, AR, maybe alien gun) can override some/all of these secondary trigger methods

func secondary_idle() -> void: # TO DO: standardize namings: either foo_secondary OR secondary_foo
	pass

func secondary_shoot() -> void:
	pass

func secondary_empty() -> void:
	pass

func secondary_reload() -> void:
	pass


# fusion pistol's secondary trigger only

func charging() -> void:
	pass

func charged() -> void:
	pass

func explode() -> void:
	pass


