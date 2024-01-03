extends Node

# engine/weapons/WeaponManager.gd


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

signal weapon_magazines_changed(weapon: Weapon) # sent by Weapon when shooting/reloading; used by HUD to update temporary ammo display 


# Timers need to be attached to a scene tree to operate but WeaponTrigger isn't a scene, so create shared timers here
@onready var primary_timer   := $PrimaryTimer
@onready var secondary_timer := $SecondaryTimer
@onready var weapon_timer    := $WeaponTimer


# weapon management

var __weapons := [] # note: Weapon.count indicates if the player is carrying 0, 1, or 2 of each
var __current_weapon_index := 1 # pistol

var current_weapon: Weapon = null: # Player accesses this property to shoot; HUD (temporatily) to get the current weapon's name and ammo
	get:
		return current_weapon


func _ready() -> void:
	__initialize_weapons(WeaponDefinitions.WEAPON_DEFINITIONS)
	InventoryManager.inventory_increased.connect(__player_picked_up_item)


func __initialize_weapons(weapon_states: Array) -> void:
	assert(__weapons.is_empty()) # for now, weapon definitions load once at launch and persist until process exits; supporting unloading/reloading is TBD when we start implementing saved game support
	__weapons.clear() # TODO: Weapon and Magazine classes will need explicitly freed
	for state in weapon_states:
		var weapon: Weapon = weapon_classes[state.weapon_class].new()
		weapon.configure(state)
		__weapons.append(weapon)
	current_weapon = __weapons[__current_weapon_index]
	current_weapon.become_current_weapon()


# used by [fast] weapon switching

var __new_weapon: Weapon = null
var __instantly: bool


func __player_picked_up_item(item: InventoryManager.InventoryItem) -> void:
	# if Player picked up a more powerful weapon than current weapon, switch to it
	if item.pickable_family == Enums.PickableFamily.WEAPON and item.pickable_type > current_weapon.weapon_item.pickable_type:
		activate_weapon_type(item.pickable_type as Enums.WeaponType)


# __switch_weapon connects this to Weapon's weapon_activity_changed signal, prior to calling Weapon.deactivate; if the weapon is busy, this listens for IDLE and calls __switch_weapon again; once weapon starts DEACTIVATING, this listens for DEACTIVATED and activates the new weapon
func __current_weapon_changed_state(_weapon: Weapon) -> void:
	match current_weapon.state:
		Weapon.State.IDLE:
			var new_weapon = __new_weapon
			__new_weapon = null
			__switch_weapon(new_weapon, __instantly)
		Weapon.State.DEACTIVATED:
			weapon_activity_changed.disconnect(__current_weapon_changed_state)
			current_weapon.resign_current_weapon()
			current_weapon = __new_weapon
			__new_weapon = null
			current_weapon.become_current_weapon()
			current_weapon.activate(__instantly)


# deactivate the current weapon and set the weapon to be activated after it
func __switch_weapon(new_weapon: Weapon, instantly: bool) -> void:
	var deactivate_current = __new_weapon == null
	__new_weapon = new_weapon
	__instantly = instantly
	if deactivate_current:
		weapon_activity_changed.connect(__current_weapon_changed_state)
		current_weapon.deactivate(instantly)


# public

# called by current Weapon when both triggers are empty and unable to reload
func current_weapon_emptied(weapon: Weapon) -> void: 
	assert(weapon == current_weapon)
	print("WeaponManager.current_weapon_emptied notification received from ", current_weapon.long_name, "; switching to previous")
	activate_previous_weapon()


# called by WeaponInHand._ready when a WIH scene is instantiated by the Player to which it's attached; for now WIHs are manually attached to Player but eventually they should be added programatically and positioned at WeaponDefinition-supplied offsets relative to head/camera, allowing weapons to be defined by scenarios
func connect_weapon_in_hand(weapon_in_hand: Node3D) -> void: 
	for weapon in __weapons:
		if weapon.weapon_type == weapon_in_hand.WEAPON_TYPE:
			weapon.connect_weapon_in_hand(weapon_in_hand)
			return
	print("Cannot find weapon for weapon-in-hand ", weapon_in_hand.WEAPON_TYPE)


# important: must be called on entering level (weapons cannot be activated before WIH are attached) # TODO: Player/Level should probably send an entering_level/exiting_level signal
func activate_current_weapon(instantly: bool = false) -> void:
	current_weapon.activate(instantly)


func activate_weapon_type(weapon_type: Enums.WeaponType, instantly: bool = false) -> void:
	for i in range(__weapons.size()):
		var weapon = __weapons[i]
		if weapon.weapon_type == weapon_type:
			if weapon != current_weapon and weapon.is_available:
				__current_weapon_index = i
				if current_weapon:
					__switch_weapon(weapon, instantly)
				else:
					current_weapon = weapon
					current_weapon.become_current_weapon()
					current_weapon.activate(__instantly)
			break


func activate_previous_weapon(instantly: bool = false) -> void:
	var new_weapon: Weapon = null
	while new_weapon != current_weapon:
		__current_weapon_index -= 1
		if __current_weapon_index < 0:
			__current_weapon_index = __weapons.size() - 1
		new_weapon = __weapons[__current_weapon_index]
		if new_weapon.is_available:
			__switch_weapon(new_weapon, instantly)
			return
	print("Can't switch weapon as no other weapons are available.")



func activate_next_weapon(instantly: bool = false) -> void:
	var new_weapon: Weapon = null
	while new_weapon != current_weapon:
		__current_weapon_index += 1
		if __current_weapon_index == __weapons.size():
			__current_weapon_index = 0
		new_weapon = __weapons[__current_weapon_index]
		if new_weapon.is_available:
			__switch_weapon(new_weapon, instantly)
			return
	print("Can't switch weapon as no other weapons are available.")
