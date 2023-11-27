extends Node

# Inventory.gd -- global Inventory manages all Weapon instances and PickableItem counts; it also provides an API by which Player can get the current Weapon instance, switch to previous/next weapon, and enable/disable a weapon when it is picked up/discarded



# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)


# TO DO: whereas M2's primary and secondary trigger inputs operate independently for dual weapons (fists, pistols, shotguns), we want to make dual-wielding largely automatic: if [loaded] dual weapons are available then always show both on screen. Pressing primary/secondary trigger fires the corresponding left/right weapon first; if user holds the trigger for repeating fire then the opposite weapon fires next, and so on. This allows user to empty one pistol (by repeatedly tapping to fire the same gun) if they wish to manage exactly when left/right pisto, reloads occur, or to hold down either trigger and have both weapons fire and reload themselves.


# TO DO: decide how best to organize player Inventory; not sure that attaching ammo count to Weapon[Trigger] is a good idea; better to have Ammunition instances for all player ammo types which are managed by Inventory; these instances can be shared with WeaponTrigger instances so that a Trigger decrements Ammunition.count when it reloads and Inventory increments it when an ammo Pickable is picked up



func _ready() -> void:
	# TO DO: __initialize_xxxx functions can be used to initialize Inventory for new game or to load saved game state
	# for now, there's only 1 weapon defined (index 0), which is for AR
	__initialize_items(Constants.ITEM_DEFINITIONS)
	__initialize_weapons(Constants.WEAPON_DEFINITIONS)
	current_weapon = __all_weapons[__current_weapon_index]
	current_weapon.activate(true)



# inventory management

var __all_items := []


class InventoryItem:
	
	var item_type:  Constants.PickableType
	var long_name:  String
	var short_name: String
	var max_count:  int
	var count:      int
	
	func configure(data: Dictionary) -> void:
		# external code must treat these properties as read-only
		self.item_type  = data.item_type
		self.long_name  = data.long_name
		self.short_name = data.short_name
		self.max_count  = data.max_count
		self.count      = data.count
	
	func try_to_increment() -> bool:
		if self.count < self.max_count:
			self.count += 1
			# TO DO: probably want to emit inventory_item_changed.emit(self) signal here, so HUD can query the Inventory and update itself
			return true
		else:
			return false
			
	func try_to_decrement() -> bool:
		if self.count > 0:
			self.count -= 1
			# TO DO: ditto
			return true
		else:
			return false # TO DO: we should probably return `self.count != 0` here so Fist can have an infinite magazine with count=-1 (i.e. never runs out)



func __initialize_items(item_definitions: Array) -> void: # TO DO: what about per-level changes, e.g. M2's Big House where player's inventory is emptied
	__all_items.clear()
	var i := 0
	for definition in item_definitions:
		assert(i as Constants.PickableType == definition.item_type)
		i += 1
		var item = InventoryItem.new()
		item.configure(definition)
		__all_items.append(item)


func get_item(item_type: Constants.PickableType) -> InventoryItem:
	return __all_items[int(item_type)]



# weapon management

var __all_weapons := [] # note: Weapon.count indicates if the player is carrying 0, 1, or 2 of each
var __current_weapon_index := 0

var current_weapon: Weapon : get = get_current_weapon # Player has read-only access to this property

func get_current_weapon() -> Weapon:
	return current_weapon


func __initialize_weapons(weapon_states: Array) -> void:
	__all_weapons.clear()
	for state in weapon_states:
		var weapon = Weapon.new()
		weapon.configure(state)
		__all_weapons.append(weapon)


func __switch_weapon(search_func: Callable) -> void:
	var new_weapon = search_func.call()
	if new_weapon != current_weapon:
		# TO DO: fast weapon switching: if user presses PREVIOUS/NEXT key repeatedly, e.g. to switch from SPNKR to Magnum, do not fully cycle through every weapon's draw and holster animations; basically, once user presses PREV/NEXT the first time, start the current weapon's deactivation and, while that is playing, monitor for any additional presses and continue switching; once user stops pressing for, say, 0.2sec, start the next activate animation but allow that animation to be quickly reversed by any additional PREV/NEXT press[es]; rinse and repeat until user makes mind up/a new weapon is brought fully to bear and is ready for use
		current_weapon.deactivate()
		await get_tree().create_timer(current_weapon.ready_time).timeout
		current_weapon = new_weapon
		current_weapon.activate()
		await get_tree().create_timer(current_weapon.ready_time).timeout


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


# TO DO: health management goes here? since health has to persist across levels, it can't be stored on per-level Player objects. Define an API here for adding/removing health/oxygen;


