extends Node

# Inventory.gd -- global Inventory manages all Weapon instances and PickableItem counts; it also provides an API by which Player can get the current Weapon instance, switch to previous/next weapon, and enable/disable a weapon when it is picked up/discarded


# TO DO: the Classic behavior was to auto-switch when a higher-powered weapon is first added to inventory; we should replicate this

# note: we won't pick up more than max weapons in TC (a Classic quirk); however, we could convert them to extra ammo which allows TC players to enjoy additional ammo over <=MD [TrojanSE did this, in addition to varying ammo quantities placed in new levels depending on player's current inventory]


# TO DO: whereas M2's primary and secondary trigger inputs operate independently for dual weapons (fists, pistols, shotguns), we want to make dual-wielding largely automatic: if [loaded] dual weapons are available then always show both on screen. Pressing primary/secondary trigger fires the corresponding left/right weapon first; if user holds the trigger for repeating fire then the opposite weapon fires next, and so on. This allows user to empty one pistol (by repeatedly tapping to fire the same gun) if they wish to manage exactly when left/right pisto, reloads occur, or to hold down either trigger and have both weapons fire and reload themselves.


# TO DO: decide how best to organize player Inventory; not sure that attaching ammo count to Weapon[Trigger] is a good idea; better to have Ammunition instances for all player ammo types which are managed by Inventory; these instances can be shared with WeaponTrigger instances so that a Trigger decrements Ammunition.count when it reloads and Inventory increments it when an ammo Pickable is picked up


signal inventory_item_increased(item: Inventory.InventoryItem)
signal inventory_item_decreased(item: Inventory.InventoryItem)



func _ready() -> void:
	__initialize_pickables(PickableDefinitions.PICKABLE_DEFINITIONS)


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
			Inventory.inventory_item_increased.emit(self)
			return true
		else:
			return false
	
	func try_to_decrement() -> bool:
		if self.count > 0:
			self.count -= 1
			Inventory.inventory_item_decreased.emit(self)
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


