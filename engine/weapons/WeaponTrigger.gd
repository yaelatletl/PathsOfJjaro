extends Node
class_name WeaponTrigger


const Projectile := preload("res://engine/actors/projectiles/Projectile.tscn")


# WeaponTrigger.gd -- each Weapon has primary and secondary triggers (for single-purpose weapons, the same WeaponTrigger is used for both)

var ammunition: Inventory.InventoryItem
var max_count: int # this belongs on ammunition_definition? except... alien gun has different limits (2000 vs 50, presumably relying on 'angular flipping' flag for the extra behavior)
var count: int

var projectile_type: Constants.ProjectileType # type of Projectile created (for fusion pistol the type of projectile created depends on which trigger is fired)
var burst_count: int # 10 for shotgun, 2 for flechette; pretty sure this is no. of Projectiles fired by a single bullet, but need to check if this is added to 1 or is `min(1,burst_count)`
var theta_error: float # projectile's accuracy
# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
var origin_delta: Vector3
var recoil_magnitude: float # applies backward impulse to Player
#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation

# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
var ready_time: float
var time_per_round: float # null # TO DO: why is this sometimes null in exported JSON Physics, not 0? (we want to avoid null)
var recovery_time: float
var charging_time: float
var reloading_time: float


var can_fire := true # TO DO: currently this is always true; should we put wait time methods on WeaponTrigger which Weapon calls after successful shoot/load_ammo call? what timers belong on Weapon itself? (bear in mind that some operations interlock, e.g. AR bullets and grenades cannot be reloaded simultaneously)


var available: bool : get = get_available # called by Inventory.previous/next_weapon to determine if a Weapon can be drawn for use (either it has ammo in it or the player has picked up more ammo since emptying it) # TO DO: rename this?

func get_available() -> bool:
	return count > 0 or get_can_reload()

func get_can_reload() -> bool: # should this be separate to get_available? if the gun is empty, calling load_ammo will try to reload it
	return self.ammunition.count != 0


func configure(data: Dictionary) -> void: # TO DO: should Weapon also pass itself as argument and assigned to `WeaponTrigger.weapon` property so that the trigger can reference the weapon to which it belongs?
	self.ammunition = Inventory.get_item(data.ammunition_type)
	self.max_count = data.max_count
	self.count = data.count
	
	self.projectile_type = data.projectile_type
	self.burst_count = data.burst_count # no. of projectiles to emit if >0, I think
	self.theta_error = data.theta_error # accuracy; apply to aim
	# offset from Player's center to Projectile's origin
	self.origin_delta = Global.array_to_vector3(data.origin_delta)
	self.recoil_magnitude = data.recoil_magnitude
	
	# timings that affect Weapon behavior; weapon-in-hand animations will use their own timings which should not be longer to avoid visual jitters when transitioning from one animation to another
	self.ready_time = data.ready_time # TO DO: how is ready_ticks different from ticks_per_round and recovery_ticks? need to check AO code
	self.time_per_round = data.time_per_round
	self.recovery_time = data.recovery_time
	self.charging_time = data.charging_time
	self.reloading_time = data.reloading_time



func shoot(projectile_origin: Vector3, projectile_direction: Vector3, shooter: PhysicsBody3D) -> bool:
	if count != 0:
		# TO DO: check if some weapons may have a delay between pulling trigger and emitting projectile; is so, move
		var projectile := Projectile.instantiate()
		Global.add_to_level(projectile)
		projectile.configure_and_shoot(self.projectile_type, projectile_origin, projectile_direction, shooter)
		#print("projectile shot: ", projectile_origin, "   ", projectile_direction)
		count -= 1 # WeaponTrigger is responsible for checking if count==0 and reloading
		return true
	else:
		return false
	
	
func load_ammo() -> bool: # this reloads instantly and returns true or false depending on success; it is up to Weapon to add timing delays and trigger the WeaponInHand animations
	var success = self.ammunition.try_to_decrement()
	if success:
		self.count = self.max_count
	return success



