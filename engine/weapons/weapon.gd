extends Node
class_name Weapon


# Weapon.gd -- managed by Inventory.gd, this represents one of the weapons available to Player in the game and holds that weapon's current state (ammo supply and current behavior) and WeaponInHand view object 

# WeaponInHand.tscn provides a weapon's visible in-hand representation: the meshes, sounds, etc for a particular weapon type - fist, pistol, fusion_gun, shotgun, assault_rifle, flechette_gun, missile_lancher, flamethrower, alien_gun - plus animation player and a standard API for triggering those animations, which Weapon's state machine calls on transitions)
#
# TO DO: to avoid barrels clipping through walls, 3D WeaponInHand models need rendered to a 2D view with transparent background; this image can then be composited on the CanvasLayer behind the HUD (unless there's a way to force WiH models *always* to render frontmost in viewport? but AFAIK only 2D canvas items provide control over z_order)


# TO DO: Ammunition class: this contains both the InventoryItem (for reloading) and the current ammo count; this allows fusion pistol to share a single Ammunition instance between both triggers (so both triggers deplete the same energy cell) whereas magnum has a separate Ammunition instance for each trigger 


# TO DO: PlayerAssetsManager which receives the following signals and sets its current_weapon to the appropriate WeaponInHand upon weapon_activated, and forward trigger signals to that (alternatively all weapons could register their own signal handlers, but then they have to decide which one of them is active); this can probably be defined as res://engine/assetlib/PlayerAssetsManager as its code shouldn't be specific to assets (it only needs to know which scenes to load for what purposes)

signal weapon_activated(weapon: Weapon)
signal weapon_deactivated(weapon: Weapon)
signal primary_trigger_fired(successfully: bool, weapon: Weapon)
signal secondary_trigger_fired(successfully: bool, weapon: Weapon)
signal primary_trigger_reloaded(weapon: Weapon)
signal secondary_trigger_reloaded(weapon: Weapon)



var primaryTrigger:   WeaponTrigger
var secondaryTrigger: WeaponTrigger # TO DO: single pistol/shotgun, and rocket launcher/flamethrower/flechette gun, have only a single firing mode (one enabled trigger) in which case should secondaryTrigger hold the same WeaponTrigger instance as primaryTrigger? (i.e. either trigger key will activate the weapon's primary trigger)


# Classic M2 weapon types:
#
# melee -- fist (this is effectively dual_wield with added custom damage behavior; we can get rid of this and fire MINOR_FIST vs MAJOR_FIST projectiles when walking vs sprinting)
# dual_wield -- pistol, shotgun (if player has only one of these weapon items in inventory, only one is shown on screen and can be fired by either trigger key)
# dual_purpose -- fusion pistol (basically multipurpose except only one trigger can be used at a time and both share the same Magazine)
# multipurpose -- assault_rifle, alien_gun (Q. what is difference between alien gun's primary and secondary firing behaviors, and what does it do when both triggers are pressed at same time? also, alien Magazine is shared between both triggers)
# normal -- rocket_launcher, flamethrower, flechette_gun (single firing mode; either trigger key fires)
#
# TO DO: we should be able to rationalize these as flags:
#
# - dual_wield:
#
#	- fist = DUAL_MODE + INTERLOCKED_TRIGGERS + SPRINT_FIRES_MAJOR_PROJECTILE + NO_MAGAZINE
#
#	- pistol, shotgun = DUAL_MODE + INTERLOCKED_TRIGGERS + INDEPENDENT_MAGAZINE
#
# - single_wield:
#
#	- fusion pistol, alien gun = DUAL_MODE + INTERLOCKED_TRIGGERS + SHARED_MAGAZINE
#
#	- AR = dual_mode + INDEPENDENT_TRIGGERS + INDEPENDENT_MAGAZINE
#
#	- flechette, flamethrower, rocket launcher = SINGLE_MODE [ + INDEPENDENT_TRIGGERS + INDEPENDENT_MAGAZINE ]


# note: dual_wield weapons are represented by a *single* Weapon instance controlling a single WIH scene that has animations for left, right, and both hands); TO DO: where the Weapon toggles between shooting left-hand and right-hand while the trigger key is held, the Weapon needs to know if the primary or secondary trigger is pulled as that determines which hand fires *first* (for first and shotgun this makes no difference to gameplay; however, the user may want to empty a pistol's magazine which they can do by tapping its trigger key repeatedly, in which case the weapon does not toggle between hands); for now, treat left hand as primary trigger and right hand as secondary trigger (we'll make it user-configurable later so that a user who places their primary trigger key on the right mouse button sees it operating the Player's right hand, but that's a UX detail we can ignore while we're working on the core implementation as most mouse users use left button as primary trigger)



var available: bool : get = get_available # TO DO:

func get_available() -> bool:
	return count > 0 and (primaryTrigger.available or secondaryTrigger.available)


var in_hand := false : get = get_in_hand # if true, the gun has finished its activate sequence

func get_in_hand() -> bool:
	return in_hand


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

var origin_offset := Vector3(0, 1, 0.5) # TO DO: this needs to be set from weapon_definition's primary/secondary_trigger (for dual-wield weapons when only 1 weapon is visible, the x-offset should probably be the average of primary and secondary x-offsets, with the WIH animation set up to show single pistol in center of screen to match)


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




# important: Player must call Weapon.shoot/reload_primary/secondary; it must not call WeaponTrigger.shoot directly as Weapon.shoot_primary/secondary are responsible for managing any interactions between triggers (e.g. AR can fire both triggers independently; dual pistols/shotguns can only fire alternately and should swap automatically while a trigger key is held; fusion can only use one trigger at a time)


func __shoot(trigger: WeaponTrigger, projectile_origin: Vector3, projectile_direction: Vector3, shooter: PhysicsBody3D) -> bool:
	if in_hand:
		# ask the trigger to fire; if the trigger can't fire (because it is empty and there's no ammo to reload it, or because it is in middle of its wait cycle), it will do nothing and return false to indicate it couldn't shoot AFAIK only multipurpose weapons can have this condition: e.g. AR has bullets but no grenades or vice-versa)
		var success = trigger.shoot(projectile_origin, projectile_direction, shooter) # note: an atomic operation ('try to shoot') is easier to reason about than sequential (`if trigger.can_shoot: trigger.shoot`)
		print("...trigger did shoot: ", success)
		return true
	else:
		print("...weapon/trigger not ready (weapon.in_hand=", in_hand, ", trigger_can_fire=", trigger.can_fire, ")")
		return false


func shoot_primary(player_origin: Vector3, projectile_direction: Vector3, shooter: PhysicsBody3D) -> void: # TO DO: pass entire Player so FIST trigger can check if player is sprinting; this also allows us to call WeaponInHand animations which are presumably attached to the Player
	print("try to shoot primary trigger... ", player_origin, "   ", projectile_direction)
	# TO DO: calculate projectile_origin
	var success = __shoot(primaryTrigger, player_origin, projectile_direction, shooter)
	primary_trigger_fired.emit(success, self)
	
	
	# TO DO: where to check if trigger needs reload and call reload method


func shoot_secondary(player_origin: Vector3, projectile_direction: Vector3, shooter: PhysicsBody3D) -> void:
	print("try to shoot secondary trigger...")
	var success = __shoot(secondaryTrigger, player_origin, projectile_direction, shooter)
	secondary_trigger_fired.emit(success, self)
	


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
	# TO DO: should reload calls return bool indicating success or failure? if both fail, the weapon would be in-hand but can't fire (although Inventory should never switch to an empty weapon, in which case all we need here is an assert to confirm correct behavior during testing)
	assert(primaryTrigger.count > 0 or secondaryTrigger.count > 0)
	weapon_activated.emit(self)
	# TO DO: play model animation when player draws weapon
	in_hand = true
	print("activated weapon ", self)


func deactivate() -> void:
	in_hand = false
	weapon_deactivated.emit(self)
	# TO DO: play model animation when player holsters weapon
	print("deactivated weapon ", self)


