extends Node

# engine/weapons/WeaponManager.gd



# TO DO: the Classic behavior was to auto-switch when a higher-powered weapon is first picked up; we should replicate this by having WeaponManager listen for InventoryManager.inventory_increased signals and checking if the picked-up item is a weapon; if it is and the Weapon is after the current weapon in __weapons then activate it

# TO DO: fast weapon switching: if user presses PREVIOUS/NEXT key repeatedly, e.g. to switch from SPNKR to Magnum, do not fully cycle through every weapon's draw and holster animations; basically, once user presses PREV/NEXT the first time, start the current weapon's deactivation and, while that is playing, monitor for any additional presses and continue switching; once user stops pressing for, say, 0.2sec, start the next activate animation but allow that animation to be quickly reversed by any additional PREV/NEXT press[es]; rinse and repeat until user makes mind up/a new weapon is brought fully to bear and is ready for use


var weapon_classes := {
	# general weapon types; these classes should be sufficient for most weapons but can be subclassed as needed
	"DualWieldWeapon": DualWieldWeapon, # pistol, shotgun
	"DualPurposeWeapon": DualPurposeWeapon, # fusion, AR, alien gun
	"SinglePurposeWeapon": SinglePurposeWeapon, # fist, flamethower, rocket launcher, flechette
	
	# Fist weapon extends SinglePurposeWeapon to perform "double-fisted" animations
	"FistWeapon": FistWeapon,
}

# signals emitted by current weapon

signal weapon_activity_changed(weapon: Weapon) # sent by Weapon.__set_current_activity upon transitioning to a new state; used by HUD to update weapon display
signal weapon_deactivated(weapon: Weapon) # sent by Weapon.__set_current_activity upon transitioning to DEACTIVATED; used by WeaponManager.__switch_weapon to await current weapon's deactivation before switching to next one (ideally it'd listen for weapon_activity_changed and check weapon.current_state==DEACTIVATED, avoiding need for an extra signal, but AFAIK `await` cannot perform the conditional check)
signal weapon_magazines_changed(weapon: Weapon) # sent by Weapon when shooting/reloading; used by HUD to update temporary ammo display 


# Timers need to be attached to a scene tree to operate but WeaponTrigger isn't a scene, so create shared timers here; TO DO: ugh, is there a better way to do this?
@onready var primary_timer   := $PrimaryTimer
@onready var secondary_timer := $SecondaryTimer
@onready var weapon_timer     := $WeaponTimer


# weapon management

var __weapons := [] # note: Weapon.count indicates if the player is carrying 0, 1, or 2 of each
var __current_weapon_index := 0

var current_weapon: Weapon = null: # Player accesses this property to shoot; HUD to get the weapon's name and current ammo
	get:
		return current_weapon


func _ready() -> void:
	print("WeaponManager initialize")
	__initialize_weapons(WeaponDefinitions.WEAPON_DEFINITIONS)


func __initialize_weapons(weapon_states: Array) -> void:
	assert(__weapons.is_empty()) # for now, weapon definitions load once at launch and persist until process exits; supporting unloading/reloading is TBD when we start implementing saved game support
	__weapons.clear() # TO DO: Weapon and Magazine classes will need explicitly freed
	for state in weapon_states:
		var weapon: Weapon = weapon_classes[state.weapon_class].new()
		weapon.configure(state)
		__weapons.append(weapon)
	current_weapon = __weapons[0]


func __switch_weapon(search_func: Callable, instantly: bool) -> void:
	var new_weapon = search_func.call()
	if new_weapon != current_weapon:
		__activate_weapon(new_weapon, instantly)


func __activate_weapon(new_weapon: Weapon, instantly: bool) -> void:
	print("deactivating ", current_weapon.debug_status)
	current_weapon.deactivate(instantly)
	await weapon_deactivated
	print("deactivated ", current_weapon.debug_status)
	current_weapon = new_weapon
	print("...will activate ", new_weapon.debug_status)
	current_weapon.activate(instantly)


# public

# notification from current Weapon

func current_weapon_emptied(weapon: Weapon) -> void: # called by Weapon when both triggers are empty and unable to reload
	assert(weapon == current_weapon)
	print("current weapon is empty: ", current_weapon.long_name, "; switching to previous")
	activate_previous_weapon()


# called by WeaponInHand._ready when a WIH scene is instantiated by the Player to which it's attached; for now WIHs are manually attached to Player but eventually they should be added programatically and positioned at WeaponDefinition-supplied offsets relative to head/camera, allowing weapons to be defined by scenarios

func connect_weapon_in_hand(weapon_in_hand: Node3D) -> void: 
	for weapon in __weapons:
		if weapon.weapon_type == weapon_in_hand.WEAPON_TYPE:
			weapon.connect_weapon_in_hand(weapon_in_hand)
			return
	print("Cannot find weapon for weapon-in-hand ", weapon_in_hand.WEAPON_TYPE)


# Player._ready MUST activate the first Weapon [instantly] after all of its WeaponInHand views have been passed to WeaponManager.connect_weapon_in_hand

func activate_weapon_type(weapon_type: Enums.WeaponType, instantly: bool) -> Enums.WeaponType:
	for i in range(__weapons.size()):
		var weapon = __weapons[i]
		if weapon.weapon_type == weapon_type and weapon != current_weapon:
			if weapon.is_available:
				__activate_weapon(weapon, instantly)
			else:
				__current_weapon_index = i
				current_weapon = weapon
				activate_previous_weapon(instantly)
				
			break
	return current_weapon.weapon_type


func activate_previous_weapon(instantly: bool = false) -> void:
	var search_func = func():
		while true:
			__current_weapon_index -= 1
			if __current_weapon_index < 0:
				__current_weapon_index = __weapons.size() - 1
			var weapon = __weapons[__current_weapon_index]
			if weapon.is_available or weapon == current_weapon:
				return weapon
	__switch_weapon(search_func, instantly)


func activate_next_weapon(instantly: bool = false) -> void:
	var search_func = func():
		while true:
			__current_weapon_index += 1
			if __current_weapon_index == __weapons.size():
				__current_weapon_index = 0
			var weapon = __weapons[__current_weapon_index]
			if weapon.is_available or weapon == current_weapon:
				return weapon
	__switch_weapon(search_func, instantly)



func activate_current_weapon(instantly: bool = false) -> void: # on entering level
	current_weapon.activate(instantly)
