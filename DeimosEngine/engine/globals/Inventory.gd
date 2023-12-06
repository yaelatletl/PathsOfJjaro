extends Node

# Inventory.gd -- global Inventory manages all Weapon instances and PickableItem counts; it also provides an API by which Player can get the current Weapon instance, switch to previous/next weapon, and enable/disable a weapon when it is picked up/discarded



# TO DO: whereas M2's primary and secondary trigger inputs operate independently for dual weapons (fists, pistols, shotguns), we want to make dual-wielding largely automatic: if [loaded] dual weapons are available then always show both on screen. Pressing primary/secondary trigger fires the corresponding left/right weapon first; if user holds the trigger for repeating fire then the opposite weapon fires next, and so on. This allows user to empty one pistol (by repeatedly tapping to fire the same gun) if they wish to manage exactly when left/right pisto, reloads occur, or to hold down either trigger and have both weapons fire and reload themselves.


# TO DO: decide how best to organize player Inventory; not sure that attaching ammo count to Weapon[Trigger] is a good idea; better to have Ammunition instances for all player ammo types which are managed by Inventory; these instances can be shared with WeaponTrigger instances so that a Trigger decrements Ammunition.count when it reloads and Inventory increments it when an ammo Pickable is picked up



func _ready() -> void:
	# TO DO: __initialize_xxxx functions can be used to initialize Inventory for new game or to load saved game state
	# for now, there's only 1 weapon defined (index 0), which is for AR
	__initialize_pickables(PickableDefinitions.PICKABLE_DEFINITIONS)
	__initialize_weapons(WeaponDefinitions.WEAPON_DEFINITIONS)
	current_weapon = __all_weapons[__current_weapon_index]
	current_weapon.activate(true)
	select_weapon(2)



# inventory management

var __all_items := []


class InventoryItem: # TO DO: presumably this extends Object by default; should we extend RefCounted instead? i.e. is there any use case where an InventoryItem may be retained elsewhere after __all_items is cleared? (there shouldn't be, since __all_items should never be called outside of an in-game lifetime but can't be certain at this stage; alternatively, we could populate __all_items once at startup and update rather than clear and recreate its existing items when starting a new game or loading state from saved game)
	
	var pickable:  Enums.PickableType
	var long_name:  String
	var short_name: String
	var max_count:  int
	var count:      int
	
	func configure(data: Dictionary) -> void:
		# external code must treat these properties as read-only
		self.pickable  = data.pickable
		self.long_name  = data.long_name
		self.short_name = data.short_name
		self.max_count  = data.max_count
		self.count      = data.count
	
	func try_to_increment() -> bool:
		if self.count < self.max_count:
			self.count += 1
			Global.inventory_item_count_changed.emit(self)
			return true
		else:
			return false
	
	func try_to_decrement() -> bool:
		if self.count > 0:
			self.count -= 1
			Global.inventory_item_count_changed.emit(self)
			return true
		else:
			return false



func __initialize_pickables(PICKABLE_DEFINITIONS: Array) -> void: # TO DO: what about per-level changes, e.g. M2's Big House where player's inventory is emptied
	__all_items.clear() # TO DO: does Array.clear explicitly .free() array items? or do we have to free each item ourselves? presumably the latter (since there's no scope-based lifetime management and Object subclasses are not memory-managed except where documented, e.g. Node, RefCounted, Resource); see: https://docs.godotengine.org/en/stable/tutorials/best_practices/node_alternatives.html 
	var i := 0
	for definition in PICKABLE_DEFINITIONS:
		assert(i as Enums.PickableType == definition.pickable)
		i += 1
		var item = InventoryItem.new()
		item.configure(definition)
		__all_items.append(item)


func get_item(pickable: Enums.PickableType) -> InventoryItem:
	return __all_items[int(pickable)]



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
		await get_tree().create_timer(current_weapon.deactivation_time).timeout
		current_weapon = new_weapon
		current_weapon.activate()
		await get_tree().create_timer(current_weapon.activation_time).timeout # TO DO: check blocking behavior; can't remember if the __switch_weapon function returns immediately, allowing previous_weapon to return as well, or if it blocks both until timeout; either way, we want to prevent weapon being used before timeout but we should do this with non-blocking Weapon.current_state transitions


func select_weapon(index: int) -> bool:
	if index >= 0 and index < __all_weapons.size():
		var weapon = __all_weapons[index]
		if weapon.available:
			current_weapon.deactivate()
			__current_weapon_index = index
			current_weapon = weapon
			current_weapon.activate()
			return true
	return false


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


# health
# note: health has to persist across levels so can't be held in per-level Player objects


# TO DO: hook up to Player and HUD via signals; add health packs, rechargers, and radiation damage areas to test map once Detonations are implemented; test it works


const OXYGEN_MAX := 100
const HEALTH_MAX := 300

var oxygen := 100:
	get:
		return oxygen

var health := 100:
	get:
		return health


func increase_oxygen(amount: float) -> void:
	if oxygen < OXYGEN_MAX:
		oxygen = min(oxygen + amount, OXYGEN_MAX)
		Global.oxygen_changed.emit()

func decrease_oxygen(amount: float) -> void:
	oxygen -= amount
	if oxygen > 0:
		Global.oxygen_changed.emit() # TO DO: should we also emit changed before died? depends if died is intended to provide notifications to objects that ignore all other health changes
	else:
		Global.player_died.emit(Enums.DamageType.SUFFOCATION)


func increase_health(amount: float) -> void:
	if health < HEALTH_MAX:
		health = min(health + amount, HEALTH_MAX)
		Global.health_changed.emit(Enums.DamageType.NONE) # TO DO: change to reusable DamageClass instance

func decrease_health(amount: float, damage_type: Enums.DamageType) -> void:
	health -= amount
	if health > 0:
		Global.health_changed.emit(damage_type) # TO DO: ditto
	else:
		Global.player_died.emit(damage_type)


