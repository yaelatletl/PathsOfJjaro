extends RefCounted
class_name Weapon


# Weapon.gd -- managed by Inventory.gd, this represents one of the weapons available to Player in the game and holds that weapon's gameplay state: primary/secondary WeaponTrigger[s] and various timers, as well as the weapon's readiness; it does NOT contain the WeaponInHand view object but should instead emit signals to which the

# assets/weapons/name/NAME.tscn provides a weapon's in-hand representation: meshes, materials, sounds, animations, etc for a particular weapon type (fist, pistol, fusion_gun, shotgun, assault_rifle, flechette_gun, missile_lancher, flamethrower, alien_gun) plus a standard API which Weapon calls to play its animations; the directory might also contain the weapon and ammo meshes for the weapon's ammo (it should not contain projectiles or explosion effects, however, as those may also be used by NPCs)



# TO DO: use a state machine to control Weapon behavior, including timings, trigger interlocks, and calling WIH methods; touch-wood all behaviors can be expressed as FSM, including dual-wield's automatic hand switching (where holding and pressing a trigger key fires that hand first, then fires the opposite hand next, and so on until key is released); use an existing FSM addon if practical, though we can roll our own if needed, e.g. try the following and potentially pick the best one:
#
# https://godotassetlibrary.com/asset/CWQ8NC/object-state-machine
# https://godotassetlibrary.com/asset/HtFKqy/finite-state-machine
# https://godotassetlibrary.com/asset/JgVHXV/gd-yafsm(finite-state-machine)
# https://godotassetlibrary.com/asset/y381op/xsm-4
#
# We can also use this FSM to manage player behaviors (particularly auto-crouch, auto-jump, auto-climb, auto-vault), and it could be used for NPCs, props, and/or scripted events too; basically we want something that is quick to configure and easy to get right


# A trigger can have the following states and transitions (TBC); in addition, triggers may interlock or behave as one, depending on weapon type; for now, let's get dual fists, dual magnums, and AR working
# 
# inactive -> activating
# 
# activating -> activated
# 
# activating -> reload
# 
# activated -> idle
# 
# idle -> shoot
# 
# shoot -> shoot
# 
# shoot -> reload
# 
# shoot -> idle
# 
# reload -> idle
# 
# reload -> empty
# 
# empty -> reload
# 
# idle -> deactivating
# 
# deactivating -> activating
# 
# deactivating -> deactivated
# 
# deactivated -> inactive
# 
# 
# 
# if dual wield:
# 
# empty -> deactivating
# 
# shoot -> shoot_other_hand -- automatically swap between hands while either trigger key is held down; Q. if fires_out_of_phase, one hand can start shooting before the other has finished shooting, so we may need a shoot -> wait -> idle where the shooting animation plays for length of shoot+wait, allowing shoot -> shoot_other transition to skip the wait part
# 
# idle -> reload_other_hand -- pistols require 2-handed reload, so the hand that needs the reload has to wait for the other to become available, then co-opt it to replace the magazine
# 




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



var weapon_type: Enums.WeaponType:
	get:
		return self.inventory_item.pickable as Enums.WeaponType


#var weapon_in_hand: WeaponInHand # TO DO: set this to a placeholder WIH when scenario WIH is not available


# TO DO: these flags are pretty confusing; they should go away in favor of FSM's current_state getter

var available: bool:
	get:
		return count > 0 and (primary_trigger.available or secondary_trigger.available)




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

var is_dual_wield: bool

# flags # TO DO: update these once finalized
#var is_automatic := true # true for AR, TOZT, alien gun, SMG; what is not clear is why it is needed since all weapons repeat-fire while trigger is held
var fires_out_of_phase: bool # true for magnum; don't think we need this: with M2 dual magnums, the firing rate is the shooting_time duration (there is no delay after shoot animation), and dual magnums fires 2x as fast; all dual-wield weapons fire two-handed with 50% phase difference
var reloads_in_one_hand := false # true for shotgun; 
var fires_under_media := false # fist, fusion, SMG -- TO DO: check fusion's underwater behavior (can't remember if both triggers shock player, or secondary only); probably best moved to WeaponTrigger and replaced with an enum to describe its behavior under water as well as above
var fires_in_vacuum: bool # TO DO: implement this (M1 campaign needs it; I forget how M3's vacuum levels disabled non-vacuum weapons but we'll just use the same flag for those too); again, probably best moved to WeaponTrigger
#var has_random_ammo_on_pickup := false # true for alien gun
var disappears_after_use := false # true for alien gun
#var secondary_has_angular_flipping := false # true for alien gun # TO DO: make this a trigger property, angular_spread

var origin_offset := Vector3(0, 1, 0.5) # TO DO: this needs to be set from weapon_definition's primary/secondary_trigger (for dual-wield weapons when only 1 weapon is visible, the x-offset should probably be the average of primary and secondary x-offsets, with the WIH animation set up to show single pistol in center of screen to match)



# TO DO: not sure how Weapon should report its state

enum WeaponActivity {
	ACTIVATING,
	ACTIVE,
	EMPTY,
	DEACTIVATING,
	DEACTIVATED,
}

var current_activity := WeaponActivity.DEACTIVATED:
	get:
		return current_activity


func __set_current_activity(new_activity: WeaponActivity) -> void:
	if new_activity != current_activity:
		match new_activity:
			
			WeaponActivity.ACTIVATING:
				Inventory.inventory_increased.connect(inventory_increased)
			
			WeaponActivity.ACTIVE:
				pass
			
			WeaponActivity.EMPTY:
				print("weapon is completely empty!")
				WeaponManager.call_deferred("current_weapon_emptied") # WeaponManager will call Weapon.deactivate
				if disappears_after_use:
					inventory_item.try_to_decrement()
			
			WeaponActivity.DEACTIVATING:
				Inventory.inventory_increased.disconnect(inventory_increased)
			
			WeaponActivity.DEACTIVATED:
				WeaponManager.weapon_deactivated.emit(self)
			
			_:
				assert(false, "unimplemented WeaponActivity: %s" % new_activity)
			
		current_activity = new_activity
		WeaponManager.weapon_activity_changed.emit(self)



func configure(weapon_data: Dictionary) -> void:
	inventory_item = Inventory.get_item(weapon_data.pickable)
	
	is_dual_wield        = inventory_item.max_count == 2
	
#	is_automatic         = weapon_data.flags.is_automatic
	fires_out_of_phase   = weapon_data.flags.fires_out_of_phase
	reloads_in_one_hand  = weapon_data.flags.reloads_in_one_hand
	fires_under_media    = weapon_data.flags.fires_under_media
	fires_in_vacuum      = weapon_data.flags.fires_in_vacuum
	disappears_after_use = weapon_data.flags.disappears_after_use
	
	
	var magazine := WeaponTrigger.Magazine.new()
	magazine.configure(weapon_data.primary_trigger, weapon_data.flags.has_random_ammo_on_pickup)
	
	var primary_controller: WeaponInHand.ViewController = (
			WeaponInHand.DualWield if is_dual_wield else 
			WeaponInHand.SingleWieldPrimary).new()
	primary_trigger = WeaponTrigger.new()
	primary_trigger.configure(weapon_data.primary_trigger, magazine, 
								weapon_data, WeaponManager.primary_timer, primary_controller)
	
	primary_trigger.trigger_state_changed.connect(primary_trigger_state_changed)
	
	if weapon_data.secondary_trigger: # dual-wield and dual-mode weapons have 2 WeaponTriggers; single-mode, single-wield Weapons have 1
		var secondary_controller: WeaponInHand.ViewController = (
				WeaponInHand.DualWield if is_dual_wield else 
				WeaponInHand.SingleWieldSecondary).new() # TO DO: might want to set this to null for single-mode weapons
		secondary_trigger = WeaponTrigger.new()
		if not weapon_data.flags.triggers_share_magazine: # weapon holds a single magazine which both triggers deplete; true for fusion and alien gun
			magazine = WeaponTrigger.Magazine.new()
			magazine.configure(weapon_data.secondary_trigger, weapon_data.flags.has_random_ammo_on_pickup)
		secondary_trigger.configure(weapon_data.secondary_trigger, magazine, 
									weapon_data, WeaponManager.secondary_timer, secondary_controller)
		secondary_trigger.trigger_state_changed.connect(secondary_trigger_state_changed)
		secondary_controller.configure(primary_trigger.magazine, secondary_trigger.magazine)
	else:
		secondary_trigger = primary_trigger
	primary_controller.configure(primary_trigger.magazine, secondary_trigger.magazine)




# called by WeaponInHand._ready via WeaponManager.add_weapon_in_hand
func add_view(weapon_in_hand: WeaponInHand) -> void:
	print("Add WIH to ", self.long_name, "   ", weapon_in_hand.hand, "   ", weapon_in_hand.name)
	if is_dual_wield:
		var trigger := primary_trigger if weapon_in_hand.hand == WeaponInHand.Hand.PRIMARY else secondary_trigger
		trigger.view_controller.set_hand(weapon_in_hand)
	else:
		primary_trigger.view_controller.set_hand(weapon_in_hand)
		secondary_trigger.view_controller.set_hand(weapon_in_hand)


func inventory_increased(item: Inventory.InventoryItem) -> void: # this is sent when any inventory item increments/decrements (while InventoryItem instances could send their own inventory_item_changed signals, allowing a WeaponTrigger to listen for a specific pickable, pickups are sufficiently rare that it shouldn't affect performance to listen to them all and filter here)
	# one trigger will be non-empty here
	if primary_trigger.should_reload_now():
		primary_trigger.reload()
	elif secondary_trigger.should_reload_now():
		secondary_trigger.reload()


# TO DO: rejig WIH controller APIs so that each Trigger is responsible for playing idle, shooting, reloading, empty animations; control of activating/deactivating animations probably must remain with Weapon as only it knows how to animate single-wield

func primary_trigger_state_changed() -> void:
	match primary_trigger.current_state:
		WeaponTrigger.TriggerState.ACTIVATED:
			print("primary trigger activated")
			__set_current_activity(WeaponActivity.ACTIVE) # weapon becomes ACTIVE as soon as either trigger is ready for use
		
		WeaponTrigger.TriggerState.SHOOTING:
			WeaponManager.weapon_magazine_changed.emit(primary_trigger.magazine, secondary_trigger.magazine) # HUD listens to this so it can update rounds count (assuming final HUD provides SPNKR display, this signal will need to be kept)
		
		WeaponTrigger.TriggerState.RELOADING:
			WeaponManager.weapon_magazine_changed.emit(primary_trigger.magazine, secondary_trigger.magazine)
		
		WeaponTrigger.TriggerState.EMPTY:
			print(WeaponActivity.keys()[current_activity], " primary is empty; secondary available: ", secondary_trigger.available)
			
			if current_activity == WeaponActivity.ACTIVE and not secondary_trigger.available: # both triggers are empty so auto-switch to preceding weapon (e.g. from AR to fusion, or from AR to pistol if fusion is unavailable) # TO DO: can we get rid of WeaponTrigger.available?
				__set_current_activity(WeaponActivity.EMPTY)
		
		WeaponTrigger.TriggerState.DEACTIVATING:
			if secondary_trigger.current_state == WeaponTrigger.TriggerState.DEACTIVATING or secondary_trigger.current_state == WeaponTrigger.TriggerState.DEACTIVATED:
				__set_current_activity(WeaponActivity.DEACTIVATING)
		
		WeaponTrigger.TriggerState.DEACTIVATED: # both triggers must finish deactivating before Weapon transitions to DEACTIVATED
			if secondary_trigger.current_state == WeaponTrigger.TriggerState.DEACTIVATED:
				__set_current_activity(WeaponActivity.DEACTIVATED)


func secondary_trigger_state_changed() -> void:
	match secondary_trigger.current_state:
		WeaponTrigger.TriggerState.ACTIVATED:
			print("secondary trigger activated")
			__set_current_activity(WeaponActivity.ACTIVE)
			
		WeaponTrigger.TriggerState.SHOOTING:
			WeaponManager.weapon_magazine_changed.emit(secondary_trigger.magazine, primary_trigger.magazine) # HUD currently listens to this so it can update temporary ammo count
		
		WeaponTrigger.TriggerState.RELOADING:
			WeaponManager.weapon_magazine_changed.emit(secondary_trigger.magazine, primary_trigger.magazine)
		
		WeaponTrigger.TriggerState.EMPTY:
			print(WeaponActivity.keys()[current_activity], " secondary is empty; primary available: ", primary_trigger.available)
			if current_activity == WeaponActivity.ACTIVE and not secondary_trigger.available: # both triggers are empty so auto-switch to preceding weapon (e.g. from AR to fusion, or from AR to pistol if fusion is unavailable)
				__set_current_activity(WeaponActivity.EMPTY)
		
		WeaponTrigger.TriggerState.DEACTIVATING:
			if primary_trigger.current_state == WeaponTrigger.TriggerState.DEACTIVATING or primary_trigger.current_state == WeaponTrigger.TriggerState.DEACTIVATED:
				__set_current_activity(WeaponActivity.DEACTIVATING)
		
		WeaponTrigger.TriggerState.DEACTIVATED:
			if primary_trigger.current_state == WeaponTrigger.TriggerState.DEACTIVATED:
				__set_current_activity(WeaponActivity.DEACTIVATED)


# draw weapon ready for use or holster it; Inventory will only call activate after checking if the weapon is available

func activate(is_instant: bool = false) -> void: # use is_instant=true to skip weapon_activating animation; use when loading saved game
	assert(primary_trigger.available or secondary_trigger.available)
	
	print("activate ", self.long_name)
	
	__set_current_activity(WeaponActivity.ACTIVATING)
	
	# always activate both triggers (unless weapon is single-wield single-mode, in which case it has only one trigger)
	primary_trigger.activate(is_instant)
	if secondary_trigger != primary_trigger:
		secondary_trigger.activate(is_instant)
		
	# play animations
#	if not is_instant:
#		if is_dual_wield:
#			if primary_trigger.available:
#				weapon_in_hand.activating_primary(self) # TO DO: change to weapon_in_hand.primary.activate(primary_trigger, self)
#			if secondary_trigger.available:
#				weapon_in_hand.activating_secondary(self)
#		else:
#			weapon_in_hand.activating_primary(self)



func deactivate() -> void: # TO DO: pass died=true when player dies? # called by __switch_weapon
	print("deactivate ", self.long_name)
	primary_trigger.deactivate(false)
	if secondary_trigger != primary_trigger:
		secondary_trigger.deactivate(false)
	__set_current_activity(WeaponActivity.DEACTIVATING)




# TO DO: this API and implementation is temporary while figuring out how Weapon should coordinate its state changes correctly

# TO DO: dual-wield behavior: pressing and holding either trigger key fires both guns alternately; only fusion, AR, and alien gun need both trigger keys for different firing modes

# TO DO: probably want start_shooting and stop_shooting methods, possibly passing primary/secondary as bool argument; this allows auto-hand swapping for dual-wield

# TO DO: primary and secondary triggers need interlocks for shooting and/or reloading

var __swap_hands := false

func shoot_primary(player: Player) -> void:
	primary_trigger.shoot(player)
	# TO DO: if is_dual_wield, alternate between triggers while both triggers can fire


func shoot_secondary(player: Player) -> void:
	secondary_trigger.shoot(player)
	# TO DO: ditto



func stop_shooting_primary() -> void:
	__swap_hands = false

func stop_shooting_secondary() -> void:
	__swap_hands = false
