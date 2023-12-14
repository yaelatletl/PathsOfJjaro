extends Node3D
class_name WeaponInHand


# weapons/WeaponInHand.gd -- abstract base class for a View class that animates one of Player's hands
#
# this file also contains DualWield, SingleWieldPrimary, and SingleWieldSecondary classes for connecting WeaponTriggers to WeaponInHand views



# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)



enum Hand { # used for dual-wield weapons
	PRIMARY,
	SECONDARY,
}

@export var hand := Hand.PRIMARY

@onready var model     := $Weapon
@onready var animation := $Animation



func _ready() -> void:
	model.visible = false
	self.reset()
	WeaponManager.add_weapon_in_hand(self) # WeaponInHand scenes attached to Player call this when Player is instantiated
	print("initialized WeaponInHand: ", self.name)


# called by WeaponTrigger via a ViewController

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

func update_ammo(primary_magazine: WeaponTrigger.Magazine, secondary_magazine: WeaponTrigger.Magazine) -> void:
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




# ViewController classes connect primary and secondary WeaponTriggers to WeaponInHand views


class ViewController extends RefCounted:
	
	var __hand: WeaponInHand # primary or secondary WIH instance
	var __primary_magazine: WeaponTrigger.Magazine # primary [or secondary, if dual-wield] magazine; used for diegetic ammo display
	var __secondary_magazine: WeaponTrigger.Magazine
	
	func configure(primary_magazine: WeaponTrigger.Magazine, secondary_magazine: WeaponTrigger.Magazine) -> void: # called when instantiated
		# TO DO: assign a dummy WIH instance to __hand, allowing Weapon to be tested with or without WIHs connected
		__primary_magazine   = primary_magazine
		__secondary_magazine = secondary_magazine
	
	func set_hand(hand: WeaponInHand) -> void: # called when Player's attached WIH are instanced
		__hand = hand



# TO DO: dual wield objects require some shared knowledge so they can correctly synchronize movements involving both hands (activating/deactivating one hand while other hand is active, requiring other hand to move away from/toward center; two-handed reload of one hand while other holds magazine and optionally gun)


class DualWield extends ViewController:
	
	var __magazine: WeaponTrigger.Magazine
	
	func set_hand(hand: WeaponInHand) -> void:
		super.set_hand(hand)
		__magazine = __primary_magazine if hand.hand == WeaponInHand.Hand.PRIMARY else __secondary_magazine
		assert(hand)
		assert(__primary_magazine)
		assert(__secondary_magazine)
	
	
	func activating() -> void: # called by Weapon when Player activates it
		__hand.activating()
		__hand.update_ammo(__magazine, __magazine)
	
	func activated() -> void: # called by Weapon when Player activates it
		__hand.activated()
		__hand.update_ammo(__magazine, __magazine)
	
	func deactivating() -> void: # called by Weapon when Player deactivates it
		__hand.deactivating()
	
	func deactivated() -> void:
		__hand.deactivated()
	
	
	func idle() -> void:
		__hand.idle()
	
	func empty() -> void:
		__hand.empty()
	
	func shooting() -> void:
		__hand.shoot()
		__hand.update_ammo(__magazine, __magazine)
	
	func reloading() -> void:
		__hand.reload()
		__hand.update_ammo(__magazine, __magazine)


class SingleWieldPrimary extends ViewController:
	
	func activating() -> void: # called by Weapon when Player activates it
		__hand.activating()
		__hand.update_ammo(__primary_magazine, __secondary_magazine)
	
	func activated() -> void: # called by Weapon when Player activates it
		__hand.activated()
		__hand.update_ammo(__primary_magazine, __secondary_magazine)
	
	func deactivating() -> void: # called by Weapon when Player deactivates it
		__hand.deactivating()

	func deactivated() -> void:
		__hand.deactivated()
	
	
	func idle() -> void:
		__hand.idle()
	
	func empty() -> void:
		__hand.empty()
	
	func shooting() -> void:
		__hand.shoot()
		__hand.update_ammo(__primary_magazine, __secondary_magazine)
	
	func reloading() -> void:
		__hand.reload()
		__hand.update_ammo(__primary_magazine, __secondary_magazine)


class SingleWieldSecondary extends ViewController:
	
	func activating() -> void: # called by Weapon when Player activates it
		pass
	
	func activated() -> void: # called by Weapon when Player activates it
		pass
	
	func deactivating() -> void: # called by Weapon when Player deactivates it
		pass
	
	func deactivated() -> void:
		pass
	
	
	func idle() -> void:
		__hand.secondary_idle()
	
	func empty() -> void:
		__hand.secondary_empty()
	
	func shooting() -> void:
		__hand.secondary_shoot()
		__hand.update_ammo(__primary_magazine, __secondary_magazine)
	
	func reloading() -> void:
		__hand.secondary_reload()
		__hand.update_ammo(__primary_magazine, __secondary_magazine)

