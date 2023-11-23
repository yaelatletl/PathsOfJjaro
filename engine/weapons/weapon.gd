extends Node
class_name Weapon


# Weapon.gd -- managed by weapon_manager.gd, this represents one of the weapons available to Player in the game and holds that weapon's current state (ammo supply and current behavior) and WeaponInHand view object 

# WeaponInHand.tscn provides a weapon's visible in-hand representation: the meshes, sounds, etc for a particular weapon type - fist, pistol, fusion_gun, shotgun, assault_rifle, flechette_gun, missile_lancher, flamethrower, alien_gun - plus animation player and a standard API for triggering those animations, which Weapon's state machine calls on transitions)




class WeaponTrigger: # TO DO: this class might be better in its own file
	
	var ammunition_type := &"ar magazine" # TO DO: how best to represent this? enum/int/&string/class/instance?
	var max_count := 52 # this belongs on ammunition_definition? except... alien gun has different limits (2000 vs 50, presumably relying on 'angular flipping' flag for the extra behavior)
	var current_count := 52
			
	var projectile_type := &"rifle bullet" # type of Projectile created (for fusion pistol the type of projectile created depends on which trigger is fired)
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
	
	
	func configure(data: Dictionary) -> void:
		self.ammunition_type = data.ammunition_type
		self.max_count = data.max_count
		self.current_count = data.current_count
			
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
	
	
	func shoot(origin: Vector3, aim: Vector3) -> void:
		if self.is_ready:
			pass
	
	
	func reload() -> void:
		pass



var primaryTrigger:   WeaponTrigger
var secondaryTrigger: WeaponTrigger # TO DO: single pistol/shotgun, and rocket launcher/flamethrower/flechette gun, have only a single firing mode (one enabled trigger) in which case should secondaryTrigger hold the same WeaponTrigger instance as primaryTrigger? (i.e. either trigger key will activate the weapon's primary trigger)

# note: in case of dual-wield weapons, where the Weapon toggles between shooting left-hand and right-hand while the trigger key is held, the Weapon needs to know if the primary or secondary trigger is pulled as that determines which hand fires *first* (for first and shotgun this makes no difference to gameplay; however, the user may want to empty a pistol's magazine which they can do by tapping its trigger key repeatedly, in which case the weapon does not toggle between hands)


# single weapons: fusion pistol, assault rifle, rocket launcher, flamethrower, flechette gun

# dual-wield weapons: fist, pistol, shotgun (note: these are also represented by a *single* Weapon instance)


# TO DO: Weapon's state machine may be a bit awkward to implement as most dual-trigger weapons tie the two triggers together behaviorally, whereas AR allows both triggers to operate independently [except when reloading]; probably another reason why Classic's Weapon physics has weaponClass property (I've not checked the AO source but I expect M2's WiH functions contain lots of `switch (weaponClass) {...}` blocks); if it's a PITA to implement all behaviors in a single class then define concrete subclasses corresponding to each M2 weaponClass:
#
# melee -- fist (this is basically dual_wield but firing a higher-damage projectile when sprinting)
# dual_wield -- pistol, shotgun (if player has only one of these weapon items in inventory, only one is shown on screen and can be fired by either trigger key)
# dual_purpose -- fusion pistol (basically multipurpose except only one trigger can be used at a time and both share the same Magazine)
# multipurpose -- assault_rifle, alien_gun (Q. what is difference between alien gun's primary and secondary firing behaviors, and what does it do when both triggers are pressed at same time? also, alien Magazine is shared between both triggers)
# normal -- rocket_launcher, flamethrower, flechette_gun (single firing mode; either trigger key fires)
#



var long_name: String # show this in Inventory overlay
var short_name: String # show this in HUD

var max_count     := 0
var current_count := 0 # how many guns of this type is player carrying? 0/1/2 (let's cap this for each weapon type to avoid Classic's TC silliness where the player's inventory can contain multiple ARs, fusions, SPNKRs, etc; either leave excess weapons on ground or else convert them to additional ammo)

# tempted to use enums just to get better typechecking
var item_type := &"assault_rifle"

var weapon_class := &"multipurpose" # TO DO: may get rid of this

# flags
var is_automatic := true
var disappears_after_use := false
var overloads := false
var has_random_ammo_on_pickup := false
var reloads_in_one_hand := false
var fires_out_of_phase := false
var fires_under_media := false
var triggers_share_ammo := false
var secondary_has_angular_flipping := false




func _ready():
	pass



func configure(data: Dictionary) -> void:
	self.long_name = data.long_name
	self.short_name = data.short_name
	
	self.max_count = data.max_count
	self.current_count = data.current_count
	
	self.item_type = data.item_type
	
	self.weapon_class = data.weapon_class
	
	# this can be rearranged later; for now, it is helpful to see all attributes
	self.is_automatic = data.flags.is_automatic
	self.disappears_after_use = data.flags.disappears_after_use
	self.overloads = data.flags.overloads
	self.has_random_ammo_on_pickup = data.flags.has_random_ammo_on_pickup
	self.reloads_in_one_hand = data.flags.reloads_in_one_hand
	self.fires_out_of_phase = data.flags.fires_out_of_phase
	self.fires_under_media = data.flags.fires_under_media
	self.triggers_share_ammo = data.flags.triggers_share_ammo
	self.secondary_has_angular_flipping = data.flags.secondary_has_angular_flipping
	
	self.primaryTrigger = WeaponTrigger.new()
	self.primaryTrigger.configure(data.primary_trigger)
	self.secondaryTrigger = WeaponTrigger.new()
	self.secondaryTrigger.configure(data.secondary_trigger)





func shoot_primary(origin: Vector3, aim: Vector3) -> void:
	if primaryTrigger.is_ready:
		primaryTrigger.shoot(origin, aim) # this only requests trigger to fire; if the trigger is empty (because there is no ammo to reload it) it will do nothing
	# TO DO: if trigger fired, play shoot animation; if not, play "empty click" animation
	# TO DO: check if trigger needs reload and call reload method


func shoot_secondary(origin: Vector3, aim: Vector3) -> void:
	if secondaryTrigger.is_ready:
		secondaryTrigger.shoot(origin, aim) # ditto
	# TO DO: check if trigger needs reload


# reload; this ties in with weapon flags and ammunition

func reload_primary() -> void:
	pass

func reload_secondary() -> void:
	pass


# draw weapon for use or holster it

func activate() -> void:
	pass
	# TO DO: play animation when player draws weapon
	# TO DO: check if weapon trigger(s) need reloaded


func deactivate() -> void:
	pass
	# TO DO: play animation when player holsters weapon
