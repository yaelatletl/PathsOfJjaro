extends Node

# engine/weapons/WeaponManager.gd



# note: these signals need to be declared in a global node (or some other Node which all emitters and listeners can access); in this case we're connecting: Weapon -> Global.SOME_SIGNAL <- HUD; the alternative would be to use Groups (which are globally defined in Project Settings), although that makes relationships less apparent and loses typechecking (since you're jumping between Project Settings tabs and code whereas signals are all done in code); for now, continue using signals for loose view-model connections and reserve Groups for a few specific use-cases, e.g.  a "SaveGame" group broadcast can tell all in-game bodies to serialize their state and pass it to SavedGameManager to be added to the outgoing JSON Dictionary


# TO DO: is it worth moving signal definitions into their own Signals.gd global? (leave them here for now; they can easily be relocated later)

# TO DO: this API is temporary until we figure out the best design for it; most of these signals might be combined into a single `weapon_state_changed([from_state: WeaponState] weapon: Weapon)` - I think this will make the weapon's state changes easier to understand and reason about (and thus robustly implement in WIH view)

# TODO: update WeaponInHand.tscn to listen to these signals to drive its animations; for now, delete the existing Glock model, etc and use a simple cuboid greybox while we work on getting the API and animation tracks designed and working right (once the code all works, the last step is to re-add the correct meshes and skeletons for Fist, Pistol, and AR WIH scenes and polish it; e.g. see the tentacle story in [https://www.youtube.com/watch?v=BQ3iqq49Ew8] for how to develop novel new scenes with lots of complex interactions one step as a time)
#
# only triggers need to be fully independent (AR allows triggers to shoot independently of each other so it's possible for both to fire in the same physics tick); all other states are interlocked (primary and secondary notifications could be merged into a single weapon_fired signal with 2 arguments for primary and secondary trigger states: JUST_FIRED/JUST_FAILED/BUSY/IDLE)


# TO DO: should weapon-in-hand sounds be played by Weapon, using a single set of AudioStreamPlayer3D nodes attached to WeaponManager? that would reduce complexity of WIH scenes and allow sharing of sound files with NPCs (Bobs, MADDs, Enforcers, other Marines in MP); we might even want to reuse gun meshes (for high LOD NPCs), restructuring res://assets/ so that resources are grouped by type (mesh/material, sound, scene, script) with subdirectories purely for human-readable groupings (e.g. wall, weapon, npc/human, npc/pfhor, prop, scripted_event, level, etc)


# used by HUD
signal weapon_activating(weapon: Weapon)
signal weapon_activated(weapon: Weapon)
signal weapon_deactivating(weapon: Weapon)
signal weapon_deactivated(weapon: Weapon)


# TO DO: probably combine these into one
signal weapon_primary_magazine_changed(magazine: WeaponTrigger.Magazine)
signal weapon_secondary_magazine_changed(magazine: WeaponTrigger.Magazine)



@onready var activation_timer := $ActivationTimer


# weapon management

var __all_weapons := [] # note: Weapon.count indicates if the player is carrying 0, 1, or 2 of each
var __current_weapon_index := 0

var current_weapon: Weapon = null : get = get_current_weapon # Player has read-only access to this property

func get_current_weapon() -> Weapon:
	return current_weapon


func _ready() -> void:
	initialize_weapons(WeaponDefinitions.WEAPON_DEFINITIONS)
	# current_weapon = __all_weapons[__current_weapon_index] # TO DO: can't activate without WIH


func add_weapon_in_hand(weapon_in_hand: Node3D) -> void:
	for weapon in __all_weapons:
		if weapon.weapon_type == weapon_in_hand.weapon_type:
			weapon.weapon_in_hand = weapon_in_hand
			#print("Connected weapon-in-hand to weapon: ", weapon_in_hand.weapon_type)
			return
	print("Cannot find weapon for weapon-in-hand ", weapon_in_hand.weapon_type)


func initialize_weapons(weapon_states: Array) -> void:
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
		await get_tree().create_timer(current_weapon.deactivation_time).timeout
		current_weapon = new_weapon
		current_weapon.activate()
		await get_tree().create_timer(current_weapon.activation_time).timeout # TO DO: check blocking behavior; can't remember if the __switch_weapon function returns immediately, allowing previous_weapon to return as well, or if it blocks both until timeout; either way, we want to prevent weapon being used before timeout but we should do this with non-blocking Weapon.current_state transitions


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

