extends Node
class_name Weapon


# Weapon.gd -- managed by Inventory.gd, this represents one of the weapons available to Player in the game and holds that weapon's current state (ammo supply and current behavior) and WeaponInHand view object 

# WeaponInHand.tscn provides a weapon's visible in-hand representation: the meshes, sounds, etc for a particular weapon type - fist, pistol, fusion_gun, shotgun, assault_rifle, flechette_gun, missile_lancher, flamethrower, alien_gun - plus animation player and a standard API for triggering those animations, which Weapon's state machine calls on transitions)
#
# TO DO: to avoid barrels clipping through walls, 3D WeaponInHand models need rendered to a 2D view with transparent background; this image can then be composited on the CanvasLayer behind the HUD (unless there's a way to force WiH models *always* to render frontmost in viewport? but AFAIK only 2D canvas items provide control over z_order)


# TO DO: Ammunition class: this contains both the InventoryItem (for reloading) and the current ammo count; this allows fusion pistol to share a single Ammunition instance between both triggers (so both triggers deplete the same energy cell) whereas magnum has a separate Ammunition instance for each trigger 


# TO DO: sort out active/ready/is_ready/etc naming conventions (note: `ready` is already reserved by Node)


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


var available: bool : get = get_available

func get_available() -> bool:
	return count > 0 and (primaryTrigger.available or secondaryTrigger.available)


var active := false : get = get_active

func get_active() -> bool:
	return active


var long_name: String # show this in Inventory overlay
var short_name: String # show this in HUD

var max_count     := 0
var count := 0 # how many guns of this type is player carrying? 0/1/2 (let's cap this for each weapon type to avoid Classic's TC silliness where the player's inventory can contain multiple ARs, fusions, SPNKRs, etc; either leave excess weapons on ground or else convert them to additional ammo)


var item_type: Constants.PickableType

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
	self.count = data.count
	
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




# important: Player must call Weapon.shoot/reload_primary/secondary; it must not call WeaponTrigger directly as Weapon is responsible for managing synchronous triggers, which it can only do in the following functions


func shoot_primary(origin: Vector3, aim: Vector3, owner: PhysicsBody3D) -> void: # TO DO: pass entire Player so FIST trigger can check if player is sprinting; this also allows us to call WeaponInHand animations which are presumably attached to the Player
	print("try to shoot primary trigger...")
	if active and primaryTrigger.ready:
		if primaryTrigger.shoot(origin, aim, owner): # this only requests trigger to fire; if the trigger is empty (because there is no ammo to reload it) it will do nothing
			pass # TO DO: if trigger fired, play shoot animation
			print("...trigger did shoot")
		else:
			pass # else play "empty click" animation
			print("...trigger failed to shoot")
		# TO DO: 
	else:
		print("...weapon/trigger not ready")
	# TO DO: check if trigger needs reload and call reload method


func shoot_secondary(origin: Vector3, aim: Vector3, owner: PhysicsBody3D) -> void:
	if active and secondaryTrigger.ready:
		pass #secondaryTrigger.shoot(origin, aim, owner) # ditto
	# TO DO: check if trigger needs reload


# reload; this ties in with weapon flags and ammunition

func reload_primary() -> void:
	if primaryTrigger.load_ammo():
		# on success, play reloading animation
		pass
	else:
		# on failure?
		pass

func reload_secondary() -> void:
	if secondaryTrigger.load_ammo():
		# on success, play reloading animation
		pass
	else:
		# on failure?
		pass


# draw weapon ready for use or holster it; Inventory will only call activate after checking if the weapon is available

func activate(is_instant: bool = false) -> void: # pass is_instant to skip draw-weapon animation
	if primaryTrigger.count == 0:
		reload_primary()
	if secondaryTrigger.count == 0:
		reload_secondary()
	# TO DO: play model animation when player draws weapon
	# TO DO:
	active = true
	print("activated weapon ", self)


func deactivate() -> void:
	active = false
	# TO DO: play model animation when player holsters weapon
	print("deactivated weapon ", self)


