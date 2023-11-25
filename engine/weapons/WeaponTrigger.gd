extends Node
class_name WeaponTrigger



var ammunition_type #: Inventory.PickableItem # TO DO: how best to represent this? enum/int/&string/class/instance?
var inventory_item: Inventory.InventoryItem
var max_count := 52 # this belongs on ammunition_definition? except... alien gun has different limits (2000 vs 50, presumably relying on 'angular flipping' flag for the extra behavior)
var count := 52
		
var projectile_type := &"rifle bullet" # type of Projectile created (for fusion pistol the type of projectile created depends on which trigger is fired)# TO DO: use enums to get better typechecking
var burst_count := 0 # 10 for shotgun, 2 for flechette; pretty sure this is no. of Projectiles fired by a single bullet, but need to check if this is added to 1 or is `min(1,burst_count)`
var theta_error := 7.03125 # projectile's accuracy
		# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
var dx := 0.0
var dz = -0.01953125
var recoil_magnitude := 0.0048828125 # applies backward impulse to Player
		#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation
		
		# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
var ready_ticks := 15 / 60 # (Classic MacOS used 60tick/sec) # TO DO: rename 'ticks' to 'time' and convert values to seconds (divide ticks by 60)
var ticks_per_round := 0 / 60 # null # TO DO: why is this sometimes null, not 0?
var recovery_ticks := 0 / 60
var charging_ticks := 0 / 60
		
		# TO DO: probably just need a single "reload_time" - the other 2 values are for pausing before/after the Classic reload animation but that delay can be built into the weapon animations
var await_reload_ticks := 10 / 60
var loading_ticks := 10 / 60
var finish_loading_ticks := 10 / 60
		#"powerup_ticks": 0 # is always 0 so presumably we don't need it

var is_ready := true


var available: bool : get = get_available

func get_available() -> bool:
	return self.count > 0 or self.can_reload


var can_reload: bool : get = get_can_reload

func get_can_reload() -> bool:
	return self.inventory_item.count != 0


func configure(data: Dictionary) -> void:
	self.ammunition_type = data.ammunition_type
	self.inventory_item = Inventory.get_item(data.ammunition_type)
	self.max_count = data.max_count
	self.count = data.count
	
	self.projectile_type = data.projectile_type
	self.burst_count = data.burst_count # no. of projectiles to emit if >0, I think
	self.theta_error = data.theta_error # accuracy; apply to aim
	# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
	self.dx = data.dx # apply dx and dz to origin # TO DO: consolidate these properties into `var origin_offset: Vector3`? that simplifies the math (it does seem odd that M2 has dx and dz; is dy fixed?)
	self.dz = data.dz
	self.recoil_magnitude = data.recoil_magnitude
	
	# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
	self.ready_ticks = data.ready_ticks
	self.ticks_per_round = data.ticks_per_round
	self.recovery_ticks = data.recovery_ticks
	self.charging_ticks = data.charging_ticks
	
	# TO DO: probably just need a single "reload_time" - the other 2 values are for pausing before/after the Classic reload animation but that delay can be built into the weapon animations
	self.await_reload_ticks = data.await_reload_ticks
	self.loading_ticks = data.loading_ticks
	self.finish_loading_ticks = data.finish_loading_ticks


func shoot(origin: Vector3, aim: Vector3, owner: PhysicsBody3D) -> bool:
	if self.is_ready:
		# TO DO
		var projectile = Projectile.new()
		# Global.current_level.get_tree().add_child(projectile) # TO DO: the current level scene should be available on Global; Global would also handle level loading and anything else that persists across process lifetime (unless Global also ontains lots of non-level logic, in which case put level management code in a dedicated `GameWorld` singleton)
		# projectile.configure_and_shoot(self.projectile_type, origin, aim, owner)
	return false
	
	
func load_ammo() -> bool: # this reloads instantly and returns true or false depending on success; it is up to Weapon to add timing delays and trigger the WeaponInHand animations
	if self.inventory_item.count > 0:
		self.inventory_item.remove_item()
	return false



