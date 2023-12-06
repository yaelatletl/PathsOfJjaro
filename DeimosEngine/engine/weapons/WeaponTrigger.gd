extends Node
class_name WeaponTrigger


# WeaponTrigger.gd


# note: a WeaponTrigger instance does not know if it is the weapon's primary or secondary trigger, or if it animates the left or right hand; this might change in future, if we find it is more useful for a WeaponTrigger to know more about its position in the Weapon, but for now let's keep it ignorant (if a WeaponTrigger user really needs to know, it can get the current weapon and compare trigger==primary_trigger and trigger==secondary_trigger to see which it is, but in general trigger operations should performed using Weapon's API as it ensures triggers are correctly synchronized)


const Projectile := preload("res://engine/actors/projectiles/Projectile.tscn")


# note: Weapon and WeaponTrigger and subsidiary classes need to support serialization to/from saved game files, so configure's data:Dictionary args must be compatible with unpacked JSON dicts


class Magazine: # the magazine used by a trigger; fusion and alien gun share a single magazine between both triggers, other weapons use a separate magazine for each trigger
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




var projectile_type: Enums.ProjectileType # type of Projectile created (for fusion pistol the type of projectile created depends on which trigger is fired) # TO DO: replace with `var projectile_class: ActorManager.ProjectileClass`; if, in future, we need to implement pooling for efficiency, all the caching and reuse mechanics can be cleanly hidden behind that API (when a projectile detonates, instead of calling `self.queue_free` it would call `ProjectileManager.dispose(self)` which can return the object to the reuse pool; while most Player and NPC projectiles don't fire in large numbers simultaneously, those that do - e.g. AR, shotgun, alien gun - might benefit from this; we can decide this once game is functionally complete and introduce if needed without having to change any existing APIs outside of ProjectileClass)

var ammo_consumption: int # 0 for fist, 10 for shotgun, 2 for flechette; 4 for fusion's secondary trigger; need to check what alien gun's triggers consume when both are fired together (you'd think it'd be 3 rounds, but the M3 physics says 2000 rounds for primary and 50 rounds for secondary) # TO DO: rename rounds_per_shot
var projectile_count: int # 10 for shotgun, 2 for flechette, 3 for alien gun (in Classic it shoots a 3-way spread when both triggers are held so we'll make that our secondary_trigger behavior); 1 for everything else
var theta_error: float # projectile's accuracy
# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
var origin_delta: Vector3
var recoil_magnitude: float # applies backward impulse to Player
#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation

# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
var time_per_round: float # null # TO DO: why is this sometimes null in exported JSON Physics, not 0? (we want to avoid null) # TO DO: rename time_per_shot
# TO DO: add time_before_shoot:float, which is the delay between the player pressing the trigger and the projectile appearing; need to put the Projectile.configure_and_shoot call on a WeaponTrigger-controlled timer so that if the player is killed in the moment after pressing the trigger the shot can be cancelled; in addition, the fusion's secondary trigger needs to to delay the charged shot until 1. gun reaches full charge and 2. user releases the trigger, so that's another reason to separate out projectile release into its own delayable function
var recovery_time: float # TO DO: in Classic I think this is time after the shooting animation has finished before the next shot can be taken (I don't think it delays auto-reloading or switching to another weapon, but need to check AO code)
var charging_time: float # used by fusion's secondary trigger; if>0, delay until fully charged and listen for user releasing the trigger key before or after full charge is achieved; if 0, proceed straight to firing directly/starting fire-after-delay timer
var reloading_time: float



# TO DO: sort these out

var can_fire := true # TO DO: currently this is always true; should we put wait time methods on WeaponTrigger which Weapon calls after successful shoot/load_ammo call? what timers belong on Weapon itself? (bear in mind that some operations interlock, e.g. AR bullets and grenades cannot be reloaded simultaneously)


var available: bool: # called by Inventory.previous/next_weapon to determine if a Weapon can be drawn for use (either it has ammo in it or the player has picked up more ammo since emptying it) # TO DO: rename this?
	get:
		return magazine.count > 0 or get_can_reload()

func get_can_reload() -> bool: # should this be separate to get_available? if the gun is empty, calling load_ammo will try to reload it
	return magazine.count != 0


func needs_reload() -> bool:
	return magazine.count <= 0





func configure(trigger_data: Dictionary, magazine: Magazine) -> void: # TO DO: should Weapon also pass itself as argument and assigned to `WeaponTrigger.weapon` property so that the trigger can reference the weapon to which it belongs?
	self.magazine = magazine
	
	self.projectile_type = trigger_data.projectile_type # TO DO: replace with: self.projectile_class = ActorManager.get_projectile_class(trigger_data.projectile_type)
	
	self.ammo_consumption = trigger_data.ammo_consumption
	self.projectile_count = trigger_data.projectile_count
	self.theta_error      = trigger_data.theta_error # accuracy; apply to aim # TO DO: separate errors for single-shot vs burst - AR's accuracy is poor in burst
	# offset from Player's center to Projectile's origin
	self.origin_delta     = Global.array_to_vector3(trigger_data.origin_delta)
	self.recoil_magnitude = trigger_data.recoil_magnitude
	
	# timings that affect Weapon behavior; weapon-in-hand animations will use their own timings which should not be longer to avoid visual jitters when transitioning from one animation to another
	self.time_per_round   = trigger_data.time_per_round
	self.recovery_time    = trigger_data.recovery_time
	self.charging_time    = trigger_data.charging_time
	self.reloading_time   = trigger_data.reloading_time


#	/* Calculate the number of rounds to fire.. */
#	if(trigger_definition->burst_count)
#	{
#		if(trigger_definition->charging_ticks)
#		{
#			rounds_to_fire= (short)((trigger_definition->burst_count*charged_amount)/FIXED_ONE);
#		} else {
#			/* Non charging weapon.. */
#			rounds_to_fire= trigger_definition->burst_count;
#		}
#	} else {
#		rounds_to_fire= 1;
#	}


func shoot(projectile_origin: Vector3, projectile_direction: Vector3, shooter: PhysicsBody3D) -> bool:
	if magazine.try_to_consume(ammo_consumption * projectile_count): # TO DO: for fusion, if there is insufficient charge left for a secondary shot, charge it anyway (Classic behavior)? or beep and flash ammo readout to notify player that magazine is too low to charge and needs to be manually emptied and auto-reloaded before it can fire a charged shot? for now, let's go with the "insufficient charge" behavior, which makes gameplay a bit more interesting than Classic
		
		# TO DO: weapons can have delay between pulling trigger and projectile creation (in Classic, check if projectile is created on WIH shooting animation's key frame, or always on frame 0; with NPCs projectile is created on animation's key frame, but WIH may or may not do it that way - I can't recall)
		# TO DO: is it possible to use class (static) methods for scene instantiation? if so, instantiate and configure_and_shoot could be merged into a single Projectile.shoot(...) method; alternatively, we can hide the details behind ActorManager.shoot_projectile(..); advantage to either approach is that it allows the callee to handle object creation so, if profiling shows that high-volume projectiles (AR, shotgun) would benefit from reusing existing instances we can implement pooling behavior behind that API without having to change the rest of the code to use it; for now though, we'll just instantiate scenes directly as needed
		for _i in range(0, projectile_count):
			Projectile.instantiate().configure_and_shoot(self.projectile_type, projectile_origin, projectile_direction, shooter)
		#print("projectile shot: ", projectile_origin, "   ", projectile_direction)
		return true
	else:
		return false
	
	
func load_ammo() -> bool: # this reloads instantly and returns true or false depending on success; it is up to Weapon to add timing delays and trigger the WeaponInHand animations
	return magazine.try_to_refill()




