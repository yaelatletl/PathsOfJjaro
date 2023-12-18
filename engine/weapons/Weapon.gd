class_name Weapon extends Object


# Weapon.gd -- managed by InventoryManager.gd, this represents one of the weapons available to Player in the game and holds that weapon's gameplay state: primary/secondary WeaponTrigger[s] and various timers, as well as the weapon's readiness; it does NOT contain the WeaponInHand view object but should instead emit signals to which the


# assets/weapons/name/NAME.tscn provides a weapon's in-hand representation: meshes, materials, sounds, animations, etc for a particular weapon type (fist, pistol, fusion_gun, shotgun, assault_rifle, flechette_gun, missile_lancher, flamethrower, alien_gun) plus a standard API which Weapon calls to play its animations; the directory might also contain the weapon and ammo meshes for the weapon's ammo (it should not contain projectiles or explosion effects, however, as those may also be used by NPCs)

# note: dual_wield weapons are represented by a *single* Weapon instance controlling two WIH scenes, each of which plays animations for one hand


# TO DO: for now, treat left hand as primary trigger and right hand as secondary trigger (i.e. most mouse users use left button as primary trigger); however, key->hand mappings for dual-wield should eventually be user-configured so a user who uses the right mouse button as their primary trigger key sees that button operating the Player's right hand (since the right button operating the Player's left hand would be visually confusing!), and vice-versa


# weapon state

# the WeaponDefinition entry
var __weapon_data:            Dictionary
var __primary_trigger_data:   Dictionary
var __secondary_trigger_data: Dictionary # this is same as primary if single-purpose or dual-wield

# gives us the current number of guns in inventory; determines if Player can wield 0, 1, or 2 guns of this [sub]class
var __weapon_item: InventoryManager.InventoryItem

# magazine[s] -- used internally and are also available externally, e.g. if HUD displays the current weapon's ammo count
var primary_magazine: Weapon.Magazine:
	get:
		return primary_magazine

var secondary_magazine: Weapon.Magazine: # this is same as primary if single-purpose or shared magazine
	get:
		return secondary_magazine

# ProjectileClass contains the projectile's configuration and spawn(...) method for launching a Projectile instance[s]
var __primary_projectile_class:   ProjectileManager.ProjectileClass
var __secondary_projectile_class: ProjectileManager.ProjectileClass

# weapon-in-hand views
var __primary_hand:   WeaponInHand
var __secondary_hand: WeaponInHand


# weapon state (Finite State Machine)

enum State {
	DEACTIVATED  = 0,
	ACTIVATING   = 1,
	ACTIVATED    = 2,
	REACTIVATING = 3,
	IDLE         = 5,
	EMPTY        = 8,
	DEACTIVATING = 9,
	
	SHOOTING_PRIMARY          = 11,
	SHOOTING_PRIMARY_ENDED    = 12,
	SHOOTING_PRIMARY_FAILED   = 13,
	
	SHOOTING_SECONDARY        = 21,
	SHOOTING_SECONDARY_ENDED  = 22,
	SHOOTING_SECONDARY_FAILED = 23,
	
	SYNCHRONIZE_SHOOTING      = 30,
	CAN_SHOOT_PRIMARY         = 31,
	CAN_SHOOT_SECONDARY       = 32,
	
	RELOADING_PRIMARY         = 41,
	RELOADING_SECONDARY       = 42,
}


var state := Weapon.State.DEACTIVATED:
	get:
		return state


# the heart of the beast; advance the FSM to its next state (some transitions may set timers, some may trigger further transitions, some may do nothing until the next transition is externally triggered)
# subclasses must override this with their own implementation; the three standard subclasses - SinglePurposeWeapon, DualPurposeWeapon, DualWieldWeapon - should cover the common use cases

func __set_state(next_state: Weapon.State) -> void:
	state = next_state


# timer callbacks; __set_state starts timers while the weapon is performing an action - activating/deactivating/shooting/reloading/etc; the following stubs should be overridden in subclasses to handle the timeout and call __set_state to transition weapon to its next state

func __weapon_timer_ended() -> void:
	pass

func __primary_timer_ended() -> void:
	pass

func __secondary_timer_ended() -> void:
	pass


# debugging support

var __state_names := {}

func name_for_state(some_state: int) -> String:
	if __state_names.is_empty():
		for key in State.keys():
			__state_names[State[key]] = key
	return __state_names[some_state]

var debug_state: String: # human-readable string since enums display as ints
	get:
		return name_for_state(state)

var debug_status: String:
	get:
		return "[Weapon %s: %s; %s,%s]" % [long_name, debug_state, primary_magazine.count, secondary_magazine.count]


# initialization

# note: when loading from saved game, load the config first then load the saved game state over it; that way, the saved game doesn't need to contain the full weapon physics but only the values that change (weapon count and current rounds for each trigger)
func configure(weapon_data: Dictionary) -> void:
	__weapon_data                = weapon_data
	__primary_trigger_data       = weapon_data.primary_trigger
	__secondary_trigger_data     = weapon_data.secondary_trigger if weapon_data.secondary_trigger else weapon_data.primary_trigger
	__weapon_item                = InventoryManager.get_item(weapon_data.pickable_type)
	__primary_projectile_class   = ProjectileManager.projectile_class_for_type(__primary_trigger_data.projectile_type)
	__secondary_projectile_class = ProjectileManager.projectile_class_for_type(__secondary_trigger_data.projectile_type)
	# create magazine[s] for this weapon
	self.primary_magazine = Weapon.Magazine.new()
	self.primary_magazine.configure(__primary_trigger_data)
	if weapon_data.triggers_share_magazine or (__weapon_item.max_count == 1 and weapon_data.secondary_trigger == null):
		self.secondary_magazine = self.primary_magazine # single-wield with 1 magazine
	else: # separate magazines for each trigger
		self.secondary_magazine = Weapon.Magazine.new()
		self.secondary_magazine.configure(__secondary_trigger_data)


# called by WeaponInHand._ready via WeaponManager.connect_weapon_in_hand
func connect_weapon_in_hand(weapon_in_hand: WeaponInHand) -> void:
	print("Add WIH to ", self.long_name, "   ", weapon_in_hand.hand, "   ", weapon_in_hand.name)
	if weapon_in_hand.hand == WeaponInHand.Hand.PRIMARY:
		__primary_hand = weapon_in_hand
	else:
		__secondary_hand = weapon_in_hand


# weapon info

var is_available: bool: # WeaponManager instantiates all Weapons, including those which the Player does not [yet] possess and those which have run out of ammo, so needs some way to determine if a weapon can/should be activated or not (i.e. Classic's weapon switching ignores empty weapons and we want to replicate that behavior)
	get:
		return __weapon_item.count > 0 and (primary_magazine.is_available or secondary_magazine.is_available)

var weapon_type: Enums.WeaponType:
	get:
		return __weapon_item.pickable_type as Enums.WeaponType

var long_name: String: # show this in InventoryManager overlay
	get:
		return __weapon_item.long_name

var short_name: String: # show this in HUD
	get:
		return __weapon_item.short_name

var max_count: int:
	get:
		return __weapon_item.max_count

var count: int: # how many guns of this type is player carrying? 0/1/2 (let's cap this for each weapon type to avoid Classic's TC silliness where the player's inventory can contain multiple ARs, fusions, SPNKRs, etc; either leave excess weapons on ground or else convert them to additional ammo)
	get:
		return __weapon_item.count

func primary_needs_reload() -> bool: # these are functions, not getters, as DualWieldWeapon overrides secondary_needs_reload and [AFAIK] there's no way for a subclass to override an existing var
	return primary_magazine.count == 0

func secondary_needs_reload() -> bool:
	return secondary_magazine.count == 0


# signal notification from InventoryManager when any pickable is picked up; subclasses may override if needed (e.g. DualWieldWeapon provides its own implementation)

func inventory_increased(item: InventoryManager.InventoryItem) -> void: # sent by any InventoryItem when it increments/decrements (while InventoryItem instances could send their own inventory_item_changed signals, allowing a WeaponTrigger to listen for a specific pickable, pickups are sufficiently rare that it shouldn't affect performance to listen to them all and filter here)
	if self.state == Weapon.State.IDLE:
		if item == self.primary_magazine.inventory_item and primary_needs_reload():
			self.__set_state(Weapon.State.RELOADING_PRIMARY)
		elif item == self.secondary_magazine.inventory_item and secondary_needs_reload():
			self.__set_state(Weapon.State.RELOADING_SECONDARY)
	# else: __set_state will do any reloading the next time it returns to IDLE state


# subclasses' __set_state method MUST call these methods on ACTIVATING and DEACTIVATED

func __connect() -> void:
	InventoryManager.inventory_increased.connect(inventory_increased)
	WeaponManager.primary_timer.timeout.connect(self.__primary_timer_ended)
	WeaponManager.secondary_timer.timeout.connect(self.__secondary_timer_ended)
	WeaponManager.weapon_timer.timeout.connect(self.__weapon_timer_ended)
	

func __disconnect() -> void:
	InventoryManager.inventory_increased.disconnect(inventory_increased)
	WeaponManager.primary_timer.timeout.disconnect(self.__primary_timer_ended)
	WeaponManager.secondary_timer.timeout.disconnect(self.__secondary_timer_ended)
	WeaponManager.weapon_timer.timeout.disconnect(self.__weapon_timer_ended)
	WeaponManager.weapon_deactivated.emit(self) # WeaponManager can now activate the next weapon


# WeaponManager calls these methods to activate and deactivate the weapon; Weapon subclasses should not need to override them

func activate(instantly: bool = false) -> void: # note: instantly is true when restoring from saved game file
	self.__set_state(Weapon.State.ACTIVATING)
	if instantly:
		self.__set_state(Weapon.State.ACTIVATED)

func deactivate(instantly: bool = false) -> void:
	self.__set_state(Weapon.State.DEACTIVATING)
	if instantly:
		self.__set_state(Weapon.State.DEACTIVATED)


# Player shoots the weapon; Weapon subclasses must override shoot and may override trigger_just_released to receive notification when user releases a trigger key

func shoot(player: Player, is_primary: bool) -> void:
	assert(false)

func trigger_just_released(is_primary: bool) -> void: # used by dual-wield weapons to stop auto-swapping hands when trigger key is released; this allows user to fire one hand only by repeatedly tapping one or other trigger key, e.g. when emptying each magnum in turn so that reloads are synchronized
	pass


# concrete subclasses should call these functions to launch projectiles

# TO DO: these two methods need to calculate projectile's origin and direction using origin offset, theta error, and angular_spread from trigger data; they also need to apply recoil_magnitude impulse to Player

func spawn_primary_projectile(player: Player) -> void:
	for i in range(0, __primary_trigger_data.projectiles_per_shot):
		__primary_projectile_class.spawn(player.global_position, player.global_look, player)


func spawn_secondary_projectile(player: Player) -> void:
	for i in range(0, __secondary_trigger_data.projectiles_per_shot):
		__secondary_projectile_class.spawn(player.global_position, player.global_look, player)



# helper class

class Magazine extends Object: # the magazine used by a trigger; fusion and alien gun share a single magazine between both triggers, other weapons assign a separate magazine to each trigger
	
	# TO DO: eventually a weapon's Magazine's class should be specified by the WeaponDefinition; this allows for other ammo management schemes, e.g. where pickable items contain a variable number of rounds which are added to a single pool of rounds from which a third-party Weapon can draw rounds individually or in batches; for now, Weapon is hardcoded to use this class for M2-style ammo management
	
	var inventory_item: InventoryManager.InventoryItem
	var max_count:      int
	var count:          int
	
	# for random ammo on pickup, use count<0
	func configure(trigger_data: Dictionary) -> void:
		inventory_item = InventoryManager.get_item(trigger_data.pickable_type)
		max_count      = trigger_data.max_count
		count          = randi_range(1, trigger_data.max_count) if trigger_data.count < 0 else trigger_data.count
		assert(count >= 0 and count <= max_count)
	
	var is_available: bool:
		get:
			return count > 0 or inventory_item.count > 0
	
	func try_to_consume(rounds: int) -> bool:
		if rounds <= count: # whereas Classic allows major fusion to be fired on nearly empty magazine, let's check if there is sufficient rounds remaining for a full charge
			count -= rounds
			return true
		else:
			return false
	
	func try_to_refill() -> bool:
		if count == 0 and inventory_item.try_to_decrement():
			count = max_count
			return true
		else:
			return false


