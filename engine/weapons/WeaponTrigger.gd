extends RefCounted
class_name WeaponTrigger


# engine/weapons/WeaponTrigger.gd


# TO DO: currently WeaponTrigger.shoot instantiates Projectiles directly; if we need object pooling for performance, the trigger should ask a global ActorManager (or global ProjectileManager) to provide the Projectile instance (while the manager could be specific to a particular projectile type, e.g. one pool for pistol bullets, another for AR bullets, etc, there probably isn't a performance saving to be had if Projectiles get their type-specific state from shared ProjectileClass instances - that instance would hold the mesh, dentonation, damage, etc scenes, parameters such as speed and max range, transitions table, and flags/behaviors such as gravity and homing)
#
# ideally we'd define `shoot` as a class method on Projectile, hiding instance creation/pooling behind that API, but PackedScenes don't expose static funcs, presumably because the script - along with the rest of the scene - must be instantiated first; at any rate, it's wasy enough to change current code from `Projectile.instantiate().configure_and_shoot(...)` to `ProjectileManager.configure_and_shoot(...)` in future

const Projectile := preload("res://engine/actors/projectiles/Projectile.tscn")




class Magazine: # the magazine used by a trigger; fusion and alien gun share a single magazine between both triggers, other weapons assign a separate magazine to each trigger
	var inventory_item: Inventory.InventoryItem
	var max_count:      int
	var count:          int
	
	func configure(trigger_data: Dictionary, has_random_ammo: bool) -> void:
		self.inventory_item = Inventory.get_item(trigger_data.pickable)
		self.max_count      = trigger_data.max_count
		self.count          = trigger_data.count # TO DO: if has_random_ammo and this is a new magazine (i.e. not one loaded from a saved game), then set count to a random number between ??? and max_count (check AO code for min count)
	
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
			


# WeaponTrigger.gd -- each Weapon has primary and secondary triggers (for single-purpose weapons, the same WeaponTrigger is used for both)

var magazine: Magazine:
	get:
		return magazine



# TO DO: signal trigger_state_changed(...)?


# TO DO: if each Trigger manages its own timings and transitions, it should probably manage its [part of the] View as well

enum TriggerState {
	DEACTIVATED,
	
	ACTIVATING,
	ACTIVATED, # trigger is now active and will transition to PREPARE
	
	PREPARE, # decide if trigger should transition to IDLE, RELOADING, or EMPTY
	
	SUSPENDED, # TO DO: Trigger needs a suspend:bool property; if true, IDLE and PREPARE will transition to SUSPENDED and remain there until suspend is set to false by Weapon; needed for interlocking operations, e.g. reloading AR triggers, firing dual wield alternating; there is also the question of pistol firing rate, as dual-wield fires more rounds/minute than single-wield; this may be why Classic physics has recovery_ticks
	
	IDLE, # it's tempting to call this READY, but that could be confused with _ready
	
	SHOOTING,
	SHOOTING_ENDED,
	
	RELOADING,
	RELOADING_ENDED,
	
	CHARGING,
	CHARGED,
	# TO DO: what about OVERCHARGING, DETONATED?
	
	# TO DO: should there be a SUSPENDED state? i.e. the trigger is IDLE but cannot change state while the hand animation is doing something else (e.g. loading the other hand's gun, performing an Action); while set (which is presumably done when IDLE), the trigger cannot perform any other action/transition; Weapon would be responsible for setting/clearing this, so it may be best as a bool flag rather than a state (which presumably resumes from idle/inactive)
	
	#WAITING, # needed?
	
	EMPTY, # a trigger can only report it is empty; it is up to the Weapon to decide what to do about it (e.g. if dual wield then deactivate that trigger's hand)
	
	DEACTIVATING,
}


signal trigger_state_changed() # Weapon listens to this to update its own status


var current_state := TriggerState.DEACTIVATED:
	get:
		return current_state


func __set_current_state(new_state: TriggerState):
	var old_state = current_state
	var next_state = new_state
	current_state = new_state
	
	match new_state:
		TriggerState.ACTIVATING:
			assert(old_state == TriggerState.DEACTIVATING or old_state == TriggerState.DEACTIVATED)
			self.view_controller.activating()
			__timer.start(activating_time)
			# set timer to transition to ACTIVATED (or straight to IDLE?) are there any use cases where transitioning to IDLE before transitioning to another state (SHOOTING/RELOADING/DEACTIVATING) is undesireable?
		
		TriggerState.ACTIVATED: # ACTIVATING -> IDLE/EMPTY
			assert(old_state == TriggerState.ACTIVATING or old_state == TriggerState.DEACTIVATED)
			self.view_controller.activated()
			next_state = TriggerState.PREPARE
		
		TriggerState.PREPARE:
			if has_rounds():
				next_state = TriggerState.IDLE
			elif magazine.try_to_refill(): # TO DO: not sure about this: may want to transition to NEEDS_RELOAD, and wait for Weapon to call reload
				next_state = TriggerState.RELOADING
			else:
				next_state = TriggerState.EMPTY
		
		TriggerState.IDLE:
			self.view_controller.idle()
		
		TriggerState.SHOOTING:
			assert(old_state == TriggerState.IDLE)
			self.view_controller.shooting()
			__timer.start(shooting_time)
		
		TriggerState.SHOOTING_ENDED: # SHOOTING -> IDLE
			assert(old_state == TriggerState.SHOOTING)
			next_state = TriggerState.PREPARE
		
		TriggerState.RELOADING:
			print("current state: ", TriggerState.keys()[current_state])
			self.view_controller.reloading()
			__timer.start(reloading_time)
		
		TriggerState.RELOADING_ENDED: # RELOADING -> IDLE
			assert(old_state == TriggerState.RELOADING)
			next_state = TriggerState.IDLE
		
		TriggerState.EMPTY:
			self.view_controller.empty()
			#next_state = TriggerState.DEACTIVATING # nope: only Weapon can make this decision, as dual-mode weapons (AR) only deactivat once *both* triggers are empty
		
		TriggerState.DEACTIVATING:
			self.view_controller.deactivating()
			__timer.start(deactivating_time)
		
		TriggerState.DEACTIVATED:
			assert(old_state == TriggerState.DEACTIVATING)
			self.view_controller.deactivated()
			__timer.disconnect("timeout", __timed_out)
		
		# TO DO: CHARGING, etc
		_:
			assert(false, "unimplemented trigger state: %s" % new_state)
	
	print(self, " Trigger ", WeaponTrigger.TriggerState.keys()[old_state], " -> ", WeaponTrigger.TriggerState.keys()[current_state])
	assert(current_state != old_state)
	trigger_state_changed.emit()
	if current_state != next_state:
		__set_current_state(next_state)



var __timer: Timer


func __timed_out() -> void:
	print(self, " __timed_out on: ", WeaponTrigger.TriggerState.keys()[current_state])
	match current_state:
		TriggerState.ACTIVATING:
			__set_current_state(TriggerState.ACTIVATED)
		TriggerState.SHOOTING:
			__set_current_state(TriggerState.SHOOTING_ENDED)
		TriggerState.RELOADING:
			__set_current_state(TriggerState.RELOADING_ENDED)
		TriggerState.DEACTIVATING:
			__set_current_state(TriggerState.DEACTIVATED)
		TriggerState.DEACTIVATED:
			print("timed out after already DEACTIVATED")
		_:
			assert(false)


var projectile_type: Enums.ProjectileType # type of Projectile created (for fusion pistol the type of projectile created depends on which trigger is fired) # TO DO: replace with `var projectile_class: ActorManager.ProjectileClass`; if, in future, we need to implement pooling for efficiency, all the caching and reuse mechanics can be cleanly hidden behind that API (when a projectile detonates, instead of calling `self.queue_free` it would call `ProjectileManager.dispose(self)` which can return the object to the reuse pool; while most Player and NPC projectiles don't fire in large numbers simultaneously, those that do - e.g. AR, shotgun, alien gun - might benefit from this; we can decide this once game is functionally complete and introduce if needed without having to change any existing APIs outside of ProjectileClass)

var ammo_consumption: int # 0 for fist, 10 for shotgun, 2 for flechette; 4 for fusion's secondary trigger; need to check what alien gun's triggers consume when both are fired together (you'd think it'd be 3 rounds, but the M3 physics says 2000 rounds for primary and 50 rounds for secondary) # TO DO: rename rounds_per_shot
var projectile_count: int # 10 for shotgun, 2 for flechette, 3 for alien gun (in Classic it shoots a 3-way spread when both triggers are held so we'll make that our secondary_trigger behavior); 1 for everything else
var theta_error: float # projectile's accuracy
# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
var origin_delta: Vector3
var recoil_magnitude: float # applies backward impulse to Player
#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation

var activating_time: float
var deactivating_time: float

var shooting_time: float
var reloading_time: float

var charging_time: float
var charged_time: float
var overcharging_time: float



# TO DO: sort these out

var can_fire := true # TO DO: currently this is always true; should we put wait time methods on WeaponTrigger which Weapon calls after successful shoot/reload call? what timers belong on Weapon itself? (bear in mind that some operations interlock, e.g. AR bullets and grenades cannot be reloaded simultaneously)


var available: bool: # called by Inventory.previous/next_weapon to determine if a Weapon can be drawn for use (either it has ammo in it or can be immediately reloaded from inventory)
	get:
		return has_rounds() or can_reload()

func can_reload() -> bool: # should this be separate to get_available? if the gun is empty, calling reload will try to reload it
	return magazine.inventory_item.count != 0

func has_rounds() -> bool:
	return magazine.count > 0

func is_empty() -> bool:
	return magazine.count <= 0


func should_reload_now() -> bool:
	return is_empty() and can_reload()


##

var view_controller: WeaponInHand.ViewController


# note: using timers is a pain here as Weapon and WeaponTrigger aren't scenes (in Godot, timers *must* be attached to a scene to operate); for now, two timers are permanently attached to WeaponManager.tscn, passed to all triggers via WeaponTrigger.configure, and connected to the current weapon's WeaponTrigger.__timed_out when the weapon and its triggers are activated

func configure(trigger_data: Dictionary, magazine: Magazine, 
				weapon_data: Dictionary, timer: Timer, hand: WeaponInHand.ViewController) -> void: # TO DO: should Weapon also pass itself as argument and assigned to `WeaponTrigger.weapon` property so that the trigger can reference the weapon to which it belongs?
	self.magazine = magazine
	
	self.view_controller = hand
	self.__timer = timer
	# TO DO: register with magazine for ammo incremented callbacks?
	
	self.projectile_type = trigger_data.projectile_type # TO DO: replace with: self.projectile_class = ProjectileManager.get_projectile_class(trigger_data.projectile_type)
	
	self.ammo_consumption = trigger_data.ammo_consumption
	self.projectile_count = trigger_data.projectile_count
	self.theta_error      = trigger_data.theta_error # accuracy; apply to aim # TO DO: separate errors for single-shot vs burst - AR's accuracy is poor in burst
	# offset from Player's center to Projectile's origin
	self.origin_delta     = Global.array_to_vector3(trigger_data.origin_delta) # TO DO: rename projectile_origin_offset?
	self.recoil_magnitude = trigger_data.recoil_magnitude
	
	# timings that affect Weapon behavior; weapon-in-hand animations will use their own timings which should not be longer to avoid visual jitters when transitioning from one animation to another
	self.activating_time   = weapon_data.activating_time
	self.deactivating_time = weapon_data.deactivating_time
	self.shooting_time     = trigger_data.shooting_time # Weapon needs to know this to offset dual-wield shooting phases by 50%; note that dual-wield doubles firing rate (keeping math simple)
	self.reloading_time    = trigger_data.reloading_time
	self.charging_time     = trigger_data.charging_time


# these methods are opportunistic: they will attempt to acquire the new state or fail/exit gracefully

func activate(instantly: bool) -> void:
	__timer.connect("timeout", __timed_out)
	if self.available:
		__set_current_state(TriggerState.ACTIVATED if instantly else TriggerState.ACTIVATING) # TO DO: might be better to pass instantly as argument and let the FSM transition through ACTIVATING to ACTIVATED without the extra waiting - i.e. it's easier to reason about states if transitions are consistent, as skipping ACTIVATING/DEACTIVATING could bypass logic attached to those stages (the question is: do we want the ability to skip that logic?)
	else:
		__set_current_state(TriggerState.EMPTY)


func deactivate(instantly: bool) -> void:
	if current_state != TriggerState.DEACTIVATED and (instantly or current_state != TriggerState.DEACTIVATING):
		__set_current_state(TriggerState.DEACTIVATED if instantly else TriggerState.DEACTIVATING)


func shoot(player: Player) -> void:
	if current_state == TriggerState.IDLE:
		if magazine.try_to_consume(ammo_consumption * projectile_count): # TO DO: for fusion, if there is insufficient charge left for a secondary shot, charge it anyway (Classic behavior)? or beep and flash ammo readout to notify player that magazine is too low to charge and needs to be manually emptied and auto-reloaded before it can fire a charged shot? for now, let's go with the "insufficient charge" behavior, which makes gameplay a bit more interesting than Classic
			
			# TO DO: weapons can have delay between pulling trigger and projectile creation (in Classic, check if projectile is created on WIH shooting animation's key frame, or always on frame 0; with NPCs projectile is created on animation's key frame, but WIH may or may not do it that way - I can't recall)
			# TO DO: is it possible to use class (static) methods for scene instantiation? if so, instantiate and configure_and_shoot could be merged into a single Projectile.shoot(...) method; alternatively, we can hide the details behind ActorManager.shoot_projectile(..); advantage to either approach is that it allows the callee to handle object creation so, if profiling shows that high-volume projectiles (AR, shotgun) would benefit from reusing existing instances we can implement pooling behavior behind that API without having to change the rest of the code to use it; for now though, we'll just instantiate scenes directly as needed
			
			__set_current_state(TriggerState.SHOOTING)
			
			# TO DO: if FIST trigger, check if player is sprinting and toggle projectile_type between MINOR_FIST and MAJOR_FIST
			
			
			var projectile_origin = player.global_position # TO DO: calculate projectile_origin relative to player's origin (see origin_delta), optionally ±dual-wield offset (not essential if projectiles aren't visible, but might be wise to implement it anyway in case other weapon physics use visible projectiles), and should be roughly where end of gun barrel appears to be (if player is looking up/down, this may also affect y offset); the origin must be [just] inside the player's radius so projectiles can't launch inside walls
			
			for _i in range(0, projectile_count):
				Projectile.instantiate().configure_and_shoot(self.projectile_type, projectile_origin, player.global_look, player)
			#print("projectile shot: ", projectile_origin, "   ", projectile_direction)
			
			# TO DO: apply self.recoil_magnitude as impulse to Player
			
		else:
			print("insufficient rounds left in magazine to fire")
			# TO DO: what state? we may want an alterate animation to indicate there is insufficient rounds left for this [charged] shot (note: this only affects fusion's secondary trigger, and only because we've changed the gameplay balance slightly so that it no longer fires a major fusion bolt if there isn't enough charge for one, whereas Classic could fire a major fusion bolt even if the magazine only held enough charge for a single minor fusion bolt before reloading; we can get around this by having the fusion's magazine display include a “low charge” line below which secondary trigger is unavailable); probably define a INSUFFICIENT_CHARGE state with insufficient_charge_time, which transitions to IDLE on timeout



func reload() -> void:
	if current_state == TriggerState.EMPTY and magazine.try_to_refill():
		__set_current_state(TriggerState.RELOADING)



