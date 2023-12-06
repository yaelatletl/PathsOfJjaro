extends Node
class_name Weapon


# Weapon.gd -- managed by Inventory.gd, this represents one of the weapons available to Player in the game and holds that weapon's gameplay state: primary/secondary WeaponTrigger[s] and various timers, as well as the weapon's readiness; it does NOT contain the WeaponInHand view object but should instead emit signals to which the

# WeaponInHand.tscn provides a weapon's visible in-hand representation: the meshes, sounds, etc for a particular weapon type - fist, pistol, fusion_gun, shotgun, assault_rifle, flechette_gun, missile_lancher, flamethrower, alien_gun - plus animation player and a standard API for triggering those animations, which Weapon's state machine calls on transitions)
#
# TO DO: to avoid barrels clipping through walls, 3D WeaponInHand models need rendered to a 2D view with transparent background; this image can then be composited on the CanvasLayer behind the HUD (unless there's a way to force WiH models *always* to render frontmost in viewport? but AFAIK only 2D canvas items provide control over z_order)


# TO DO: Ammunition class: this contains both the InventoryItem (for reloading) and the current ammo count; this allows fusion pistol to share a single Ammunition instance between both triggers (so both triggers deplete the same energy cell) whereas magnum has a separate Ammunition instance for each trigger 


# TO DO: PlayerAssetsManager which receives the following signals and sets its current_weapon to the appropriate WeaponInHand upon weapon_activated, and forward trigger signals to that (alternatively all weapons could register their own signal handlers, but then they have to decide which one of them is active); this can probably be defined as res://engine/assetlib/PlayerAssetsManager as its code shouldn't be specific to assets (it only needs to know which scenes to load for what purposes)



var primary_trigger:   WeaponTrigger
var secondary_trigger: WeaponTrigger # TO DO: single pistol/shotgun, and rocket launcher/flamethrower/flechette gun, have only a single firing mode (one enabled trigger) in which case should secondary_trigger hold the same WeaponTrigger instance as primary_trigger? (i.e. either trigger key will activate the weapon's primary trigger)


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



# TO DO: these flags are pretty confusing; it may be better to expose a read-only current_state enum which indicates the weapon's current state

var available: bool:
	get:
		return count > 0 and (primary_trigger.available or secondary_trigger.available)


var in_hand := false:
	get: # if true, the gun has finished its activate sequence
		return in_hand



var long_name: String: # show this in Inventory overlay
	get:
		return inventory_item.long_name


var short_name: String: # show this in HUD
	get:
		return inventory_item.short_name

var max_count: int:
	get:
		return inventory_item.max_count

var count: int: # how many guns of this type is player carrying? 0/1/2 (let's cap this for each weapon type to avoid Classic's TC silliness where the player's inventory can contain multiple ARs, fusions, SPNKRs, etc; either leave excess weapons on ground or else convert them to additional ammo)
	get:
		return inventory_item.count



var inventory_item: Inventory.InventoryItem


#var weapon_class := &"multipurpose" # TO DO: replace this property with additional bool flags (the Classic flags below already cover most of the behavioral differences)

# flags # TO DO: update these once finalized
#var is_automatic := true # true for AR, TOZT, alien gun, SMG; what is not clear is why it is needed since all weapons repeat-fire while trigger is held
var fires_out_of_phase := false # true for magnum; don't think we need this
var reloads_out_of_phase := false # true for shotgun; we shouldn't need this flag as AFAIK this only affects WIH's animation (unlike Classic, which has 2 separate animation players for left and right hands, we only have one animation player for both)
var fires_under_media := false # fist, fusion, SMG -- TO DO: check fusion's underwater behavior (can't remember if both triggers shock player, or secondary only); probably best moved to WeaponTrigger and replaced with an enum to describe its behavior under water as well as above
var fires_in_vacuum: bool # TO DO: implement this (M1 campaign needs it; I forget how M3's vacuum levels disabled non-vacuum weapons but we'll just use the same flag for those too); again, probably best moved to WeaponTrigger
#var has_random_ammo_on_pickup := false # true for alien gun
#var disappears_after_use := false # true for alien gun
#var secondary_has_angular_flipping := false # true for alien gun # TO DO: make this a trigger property, angular_spread

var origin_offset := Vector3(0, 1, 0.5) # TO DO: this needs to be set from weapon_definition's primary/secondary_trigger (for dual-wield weapons when only 1 weapon is visible, the x-offset should probably be the average of primary and secondary x-offsets, with the WIH animation set up to show single pistol in center of screen to match)


var activation_time: float # TO DO: M3 physics has this on weapon, not trigger, so I suspect it's time it takes between selecting weapon and weapon being ready to take its first shot
var deactivation_time: float



func _ready():
	pass


func configure(weapon_data: Dictionary) -> void:
	self.inventory_item = Inventory.get_item(weapon_data.pickable)
	
	#self.weapon_class = weapon_data.weapon_class
	
	self.activation_time                = weapon_data.activation_time
	self.deactivation_time              = weapon_data.deactivation_time
	
#	self.is_automatic                   = weapon_data.flags.is_automatic
	self.fires_out_of_phase             = weapon_data.flags.fires_out_of_phase
#	self.reloads_out_of_phase            = weapon_data.flags.reloads_out_of_phase
	self.fires_under_media              = weapon_data.flags.fires_under_media
	self.fires_in_vacuum                = weapon_data.flags.fires_in_vacuum
#	self.has_random_ammo_on_pickup      = weapon_data.flags.has_random_ammo_on_pickup
#	self.disappears_after_use           = weapon_data.flags.disappears_after_use
#	self.secondary_has_angular_flipping = weapon_data.flags.secondary_has_angular_flipping
	
	# TO DO: private Weapon.Magazine class so both triggers can share a single magazinw when Fusion
	var magazine = WeaponTrigger.Magazine.new()
	magazine.configure(weapon_data.primary_trigger, weapon_data.flags.has_random_ammo_on_pickup)
	self.primary_trigger = WeaponTrigger.new()
	self.primary_trigger.configure(weapon_data.primary_trigger, magazine)
	
	self.secondary_trigger = WeaponTrigger.new()
	if not weapon_data.flags.triggers_share_magazine: # weapon holds a single magazine which both triggers deplete; true for fusion and alien gun
		magazine = WeaponTrigger.Magazine.new()
		magazine.configure(weapon_data.secondary_trigger, weapon_data.flags.has_random_ammo_on_pickup)
	self.secondary_trigger.configure(weapon_data.secondary_trigger, magazine)




# important: Player must call Weapon.shoot/reload_primary/secondary; it must not call WeaponTrigger.shoot directly as Weapon.shoot_primary/secondary are responsible for managing any interactions between triggers (e.g. AR can fire both triggers independently; dual pistols/shotguns can only fire alternately and should swap automatically while a trigger key is held; fusion can only use one trigger at a time)

# TO DO: this API and implementation is temporary while figuring out how Weapon should coordinate its state changes correctly



func shoot_primary(player_origin: Vector3, projectile_direction: Vector3, shooter: PhysicsBody3D) -> void: # TO DO: pass entire Player so FIST trigger can check if player is sprinting; this also allows us to call WeaponInHand animations which are presumably attached to the Player
	# TO DO: calculate projectile_origin
	# ask the trigger to fire; if the trigger can't fire (because it is empty and there's no ammo to reload it, or because it is in middle of its wait cycle), it will do nothing and return false to indicate it couldn't shoot AFAIK only multipurpose weapons can have this condition: e.g. AR has bullets but no grenades or vice-versa)
	var success = primary_trigger.shoot(player_origin, projectile_direction, shooter)
	print("try to shoot primary trigger:", success)
	if success:
		Global.primary_trigger_fired.emit(success)
		Global.primary_magazine_count_changed.emit(primary_trigger.magazine)
	else:
		Global.primary_trigger_clicked.emit()
	if primary_trigger.magazine.count == 0:
		reload_primary()


func shoot_secondary(player_origin: Vector3, projectile_direction: Vector3, shooter: PhysicsBody3D) -> void:
	# TO DO: ditto
	var success = secondary_trigger.shoot(player_origin, projectile_direction, shooter)
	print("try to shoot secondary trigger: ", success)
	if success:
		Global.secondary_trigger_fired.emit(success)
		Global.secondary_magazine_count_changed.emit(secondary_trigger.magazine)
	else:
		Global.secondary_trigger_clicked.emit()
	if secondary_trigger.magazine.count == 0:
		reload_secondary()


# reload; this ties in with weapon flags and ammunition

# TO DO: timings; these might be in state machine, caveat that shotguns allow out-of-phase reloading

func reload_primary() -> void:
	var success = primary_trigger.load_ammo()
	#print("try to reload primary trigger: ", success)
	if success:
		Global.primary_trigger_reloaded.emit(success)
	# TO DO: if reload failed, need to change that trigger's state so its 

func reload_secondary() -> void:
	var success = secondary_trigger.load_ammo()
	#print("try to reload primary trigger: ", success)
	if success:
		Global.secondary_trigger_reloaded.emit(success)


# draw weapon ready for use or holster it; Inventory will only call activate after checking if the weapon is available

func activate(is_instant: bool = false) -> void: # pass is_instant to skip weapon_activating animation
	if not is_instant:
		Global.weapon_activating.emit(self)
	
	# TO DO: reloads need to be synchronized so these will move into Weapon.set_current_state (also need to check when Classic AR auto-reloads after running out of ammo for one or both triggers)
	if primary_trigger.magazine.count == 0:
		reload_primary()
	if secondary_trigger.magazine.count == 0:
		reload_secondary()
	
	# TO DO: should reload calls return bool indicating success or failure? if both fail, the weapon would be in-hand but can't fire (although Inventory should never switch to an empty weapon, in which case all we need here is an assert to confirm correct behavior during testing)
	assert(primary_trigger.magazine.count > 0 or secondary_trigger.magazine.count > 0)
	# TO DO: timer
	
	Global.weapon_activated.emit(self) # TO DO: are weapon_[de]activated signals needed? should they be named weapon_ready, weapon_sleep? (advantage of a 'weapon_ready' signal/state is it can also be sent after user stops firing; WIH can e.g. use this to check its own state changes are synchronized with Weapon, or to interrupt over-long animation with RESET so WIH immediately enters its idle state)
	# TO DO: play model animation when player draws weapon
	in_hand = true
	print("activated weapon ", self.long_name)


func deactivate() -> void:
	Global.weapon_deactivating.emit(self)
	in_hand = false
	# TO DO: timer
	Global.weapon_deactivated.emit(self)
	# TO DO: play model animation when player holsters weapon
	print("deactivated weapon ", self.long_name)


