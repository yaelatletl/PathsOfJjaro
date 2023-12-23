extends Node

# InventoryManager.gd -- global InventoryManager manages all Weapon instances and PickableItem counts; it also provides an API by which Player can get the current Weapon instance, switch to previous/next weapon, and enable/disable a weapon when it is picked up/discarded


# TO DO: on TC, remove max_count limits on ammo items only


signal inventory_increased(item: InventoryManager.InventoryItem)
signal inventory_decreased(item: InventoryManager.InventoryItem)



func _ready() -> void:
	__initialize_inventory(InventoryDefinitions.INVENTORY_DEFINITIONS)


# inventory management

var __all_items := []


class InventoryItem extends Object: # TO DO: presumably this extends Object by default; should we extend RefCounted instead? i.e. is there any use case where an InventoryItem may be retained elsewhere after __all_items is cleared? (there shouldn't be, since __all_items should never be called outside of an in-game lifetime but can't be certain at this stage; alternatively, we could populate __all_items once at startup and update rather than clear and recreate its existing items when starting a new game or loading state from saved game)
	
	var pickable_type:   Enums.PickableType
	var pickable_family: Enums.PickableFamily
	var long_name:       String
	var short_name:      String
	var max_count:       int
	var count:           int
	
	func configure(data: Dictionary) -> void:
		# external code must treat these properties as read-only
		self.pickable_type   = data.pickable_type
		self.pickable_family = data.pickable_family
		self.long_name       = data.long_name
		self.short_name      = data.short_name
		self.max_count       = data.max_count
		self.count           = data.count
	
	func try_to_increment() -> bool:
		if self.count < self.max_count: # TO DO: on TC the max_count must be ignored on ammo only; do not exceed max_count for weapons, keycards, etc as those will be limited for a reason
			self.count += 1
			InventoryManager.inventory_increased.emit(self)
			return true
		else:
			return false
	
	func try_to_decrement() -> bool:
		if self.count > 0:
			self.count -= 1
			InventoryManager.inventory_decreased.emit(self)
			return true
		else:
			return false



func __initialize_inventory(INVENTORY_DEFINITIONS: Array) -> void: # TO DO: what about per-level changes, e.g. M2's Big House where player's inventory is emptied
	__all_items.clear() # TO DO: does Array.clear explicitly .free() array items? or do we have to free each item ourselves? presumably the latter (since there's no scope-based lifetime management and Object subclasses are not memory-managed except where documented, e.g. Node, RefCounted, Resource); see: https://docs.godotengine.org/en/stable/tutorials/best_practices/node_alternatives.html 
	var i := 0
	for definition in INVENTORY_DEFINITIONS:
		assert(i as Enums.PickableType == definition.pickable_type)
		i += 1
		var item = InventoryItem.new()
		item.configure(definition)
		__all_items.append(item)


func get_item(pickable_type: Enums.PickableType) -> InventoryItem:
	return __all_items[int(pickable_type)]




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
		Global.health_changed.emit(Enums.DamageType.NONE)

func decrease_health(amount: float, damage_type: Enums.DamageType) -> void: # TO DO: change damage_type to DamageClass instance; Q. should DamageClass include amount? (problem is lava where the amount of damage varies depending on how much of player is submerged)
	health -= amount
	if health > 0:
		Global.health_changed.emit(damage_type) # TO DO: ditto
	else:
		Global.player_died.emit(damage_type)


