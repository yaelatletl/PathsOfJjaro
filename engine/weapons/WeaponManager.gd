extends Node

# engine/weapons/WeaponManager.gd


# signals emitted by current weapon

signal weapon_activity_changed(weapon: Weapon) # used by HUD to update weapon display
signal weapon_deactivated(weapon: Weapon) # used by WeaponManager.__switch_weapon
signal weapon_magazine_changed(primary_magazine: WeaponTrigger.Magazine, secondary_magazine: WeaponTrigger.Magazine) # used by HUD to update temporary ammo display 


# Timers need to be attached to a scene tree to operate but WeaponTrigger isn't a scene, so create shared timers here; TO DO: ugh, is there a better way to do this?
@onready var primary_timer   := $PrimaryTimer
@onready var secondary_timer := $SecondaryTimer


# weapon management

var __all_weapons := [] # note: Weapon.count indicates if the player is carrying 0, 1, or 2 of each
var __current_weapon_index := 0

var current_weapon: Weapon = null: # Player accesses this property to shoot; HUD to get the weapon's name and current ammo
	get:
		return current_weapon


func _ready() -> void:
	__initialize_weapons(WeaponDefinitions.WEAPON_DEFINITIONS)


func __initialize_weapons(weapon_states: Array) -> void:
	__all_weapons.clear()
	for state in weapon_states:
		var weapon := Weapon.new()
		weapon.configure(state)
		__all_weapons.append(weapon)


func __switch_weapon(search_func: Callable) -> void:
	var new_weapon = search_func.call()
	if new_weapon != current_weapon:
		# TO DO: fast weapon switching: if user presses PREVIOUS/NEXT key repeatedly, e.g. to switch from SPNKR to Magnum, do not fully cycle through every weapon's draw and holster animations; basically, once user presses PREV/NEXT the first time, start the current weapon's deactivation and, while that is playing, monitor for any additional presses and continue switching; once user stops pressing for, say, 0.2sec, start the next activate animation but allow that animation to be quickly reversed by any additional PREV/NEXT press[es]; rinse and repeat until user makes mind up/a new weapon is brought fully to bear and is ready for use
		current_weapon.deactivate()
		await weapon_deactivated
		current_weapon = new_weapon
		current_weapon.activate()


# public

# called by WeaponInHand._ready when instantiated by the Player to which it's attached; for now WIHs are manually attached to Player scene but eventually they should be added programatically and positioned at WeaponDefinition-supplied offsets relative to head/camera
func add_weapon_in_hand(weapon_in_hand: Node3D) -> void: 
	for weapon in __all_weapons:
		if weapon.weapon_type == weapon_in_hand.WEAPON_TYPE:
			weapon.add_view(weapon_in_hand)
			return
	print("Cannot find weapon for weapon-in-hand ", weapon_in_hand.WEAPON_TYPE)


# Player._ready is responsible for activating a Weapon, after all of its WIHs have been added to Weapons
func activate_weapon_now(weapon_type: Enums.WeaponType) -> Enums.WeaponType:
	for i in range(__all_weapons.size()):
		var weapon = __all_weapons[i]
		if weapon.weapon_type == weapon_type:
			if weapon.available:
				if current_weapon:
					current_weapon.deactivate()
			__current_weapon_index = i
			current_weapon = weapon
			current_weapon.activate()
			break
	return current_weapon.weapon_type


func current_weapon_emptied() -> void: # called by Weapon when both triggers are empty and unable to reload
	print("current weapon is empty: ", current_weapon.long_name, "; switching to previous")
	previous_weapon()


func previous_weapon() -> void:
	var search_func = func():
		while true:
			__current_weapon_index -= 1
			if __current_weapon_index < 0:
				__current_weapon_index = __all_weapons.size() - 1
			var weapon = __all_weapons[__current_weapon_index]
			if weapon.available or weapon == current_weapon:
				return weapon
	__switch_weapon(search_func)


func next_weapon() -> void:
	var search_func = func():
		while true:
			__current_weapon_index += 1
			if __current_weapon_index == __all_weapons.size():
				__current_weapon_index = 0
			var weapon = __all_weapons[__current_weapon_index]
			if weapon.available or weapon == current_weapon:
				return weapon
	__switch_weapon(search_func)

