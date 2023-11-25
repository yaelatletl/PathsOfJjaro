extends Node

# Inventory.gd -- global Inventory manages all Weapon instances and PickableItem counts; it also provides an API by which Player can get the current Weapon instance, switch to previous/next weapon, and enable/disable a weapon when it is picked up/discarded



# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)


# TO DO: whereas M2's primary and secondary trigger inputs operate independently for dual weapons (fists, pistols, shotguns), we want to make dual-wielding largely automatic: if [loaded] dual weapons are available then always show both on screen. Pressing primary/secondary trigger fires the corresponding left/right weapon first; if user holds the trigger for repeating fire then the opposite weapon fires next, and so on. This allows user to empty one pistol (by repeatedly tapping to fire the same gun) if they wish to manage exactly when left/right pisto, reloads occur, or to hold down either trigger and have both weapons fire and reload themselves.


# TO DO: decide how best to organize player Inventory; not sure that attaching ammo count to Weapon[Trigger] is a good idea; better to have Ammunition instances for all player ammo types which are managed by Inventory; these instances can be shared with WeaponTrigger instances so that a Trigger decrements Ammunition.count when it reloads and Inventory increments it when an ammo Pickable is picked up


const ITEM_DEFINITIONS := [ # for now, this array is ordered same as PickableType enum and M2 map data, so we can convert map JSONs to PickableItems
	# TO DO: including item_type here is probably redundant: just use `idx as Constants.PickableType` to cast the array index to the corresponding enum
	{"item_type": Constants.PickableType.FIST,                  "long_name": "Fist",                  "short_name": "",     "max_count":  2, "count":  2}, # TO DO: fix counts, max_counts, short_name
	{"item_type": Constants.PickableType.MAGNUM_PISTOL,         "long_name": "Magnum Pistol",         "short_name": "",     "max_count":  2, "count":  1},
	{"item_type": Constants.PickableType.MAGNUM_MAGAZINE,       "long_name": "Magnum Magazine",       "short_name": "MEGA", "max_count": 50, "count":  7},
	{"item_type": Constants.PickableType.PLASMA_PISTOL,         "long_name": "Plasma Pistol",         "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.PLASMA_ENERGY_CELL,    "long_name": "Plasma Energy Cell",    "short_name": "ZEUS", "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.ASSAULT_RIFLE,         "long_name": "Assault Rifle",         "short_name": "",     "max_count": 15, "count":  1},
	{"item_type": Constants.PickableType.AR_MAGAZINE,           "long_name": "AR Magazine",           "short_name": "MA75", "max_count":  8, "count":  4},
	{"item_type": Constants.PickableType.AR_GRENADE_MAGAZINE,   "long_name": "AR Grenade Magazine",   "short_name": "GREN", "max_count":  1, "count":  2},
	{"item_type": Constants.PickableType.MISSILE_LAUNCHER,      "long_name": "Missile Launcher",      "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.MISSILE_2_PACK,        "long_name": "Missile 2-Pack",        "short_name": "SSM",  "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.INVISIBILITY_POWERUP,  "long_name": "Invisibility Powerup",  "short_name": "",     "max_count":  1, "count":  0}, # TO DO: powerups are probably a special case, requiring their own subclass that performs notifications and timeout
	{"item_type": Constants.PickableType.INVINCIBILITY_POWERUP, "long_name": "Invincibility Powerup", "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.INFRAVISION_POWERUP,   "long_name": "Infravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.ALIEN_WEAPON,          "long_name": "Alien Weapon",          "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.ALIEN_WEAPON_AMMO,     "long_name": "Alien Weapon Ammo",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.FLAMETHROWER,          "long_name": "Flamethrower",          "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.FLAMETHROWER_CANISTER, "long_name": "Flamethrower Canister", "short_name": "TOZT", "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.EXTRAVISION_POWERUP,   "long_name": "Extravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.OXYGEN_POWERUP,        "long_name": "Oxygen Powerup",        "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.ENERGY_POWERUP_X1,     "long_name": "Energy Powerup x1",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.ENERGY_POWERUP_X2,     "long_name": "Energy Powerup x2",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.ENERGY_POWERUP_X3,     "long_name": "Energy Powerup x3",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.SHOTGUN,               "long_name": "Shotgun",               "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.SHOTGUN_CARTRIDGES,    "long_name": "Shotgun Cartridges",    "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.SPHT_DOOR_KEY,         "long_name": "S'pht Door Key",        "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.UPLINK_CHIP,           "long_name": "Uplink Chip",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.LIGHT_BLUE_BALL,       "long_name": "Light Blue Ball",       "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.THE_BALL,              "long_name": "The Ball",              "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.VIOLET_BALL,           "long_name": "Violet Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.YELLOW_BALL,           "long_name": "Yellow Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.BROWN_BALL,            "long_name": "Brown Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.ORANGE_BALL,           "long_name": "Orange Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.BLUE_BALL,             "long_name": "Blue Ball",             "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.GREEN_BALL,            "long_name": "Green Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.SUBMACHINE_GUN,        "long_name": "Submachine Gun",        "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": Constants.PickableType.SUBMACHINE_GUN_CLIP,   "long_name": "Submachine Gun Clip",   "short_name": "",     "max_count":  1, "count":  0},
]


const WEAPON_DEFINITIONS := [
	# TO DO: get AR working correctly, then add remaining weapon definitions here
	
	# final M1 weapon order should be: fist, magnum, fusion, AR, alien gun, flamethrower, rocket launcher; this ensures that when alien gun/flamethrower runs empty, the Player switches to less powerful, more general-purpose weapon (typically AR) and avoids Classic's annoying flaw of auto-switching from alien gun to SPNKR (very dangerous!)
	{
		
		"long_name": "MA75B Assault Rifle", # show this in Inventory overlay
		"short_name": "MA75B", # show this in HUD
		
		"max_count": 1,
		"count": 1, # 1 for testing; normally 0 for everything except fist (2) and pistol (1)
		
		"item_type": Constants.PickableType.ASSAULT_RIFLE,
		
		#"powerup_type": null,
		"weapon_class": "multipurpose", # how does this influence weapon behaviors? (e.g. I think melee affects run-punch damage; what else?)
		
		# TO DO:
		"flags": {
			"is_automatic": true, # true for AR, SPNKR, flamethrower, alien gun, flechette gun; not sure what it does though as other weapons also fire repeatedly when trigger key is held down
			"disappears_after_use": false, # true for alien gun
			#"plays_instant_shell_casing_sound": false, # always false
			"overloads": false, # true for fusion pistol (Q. what is overload timeout in M2? check AO code)
			"has_random_ammo_on_pickup": false, # true for alien gun
			#"powerup_is_temporary": false, # always false
			"reloads_in_one_hand": false, # true for shotgun
			"fires_out_of_phase": false, # true for pistol but not sure what it does, if anything
			"fires_under_media": false, # true for fists, fusion pistol, flechette gun (note that firing fusion underwater causes radius damage, though not sure if this is the Projectile or Weapon which does this; Q. does firing fusion into water also do radius damage, or is it only when weapon itself is submerged?)
			"triggers_share_ammo": false, # true for fusion pistol and alien gun, false for others
			"secondary_has_angular_flipping": false # true for alien gun
		},
		
		# TO DO: these belong in weapon assets's shoot and reload animations
		#"idle_height": 1.1666565,
		#"bob_amplitude": 0.028564453,
		#"idle_width": 0.5,
		#"horizontal_amplitude": 0.0,
		#"kick_height": 0.0625, # presumably M2 WU
		#"reload_height": 0.75,

		"primary_trigger": {
			
			"ammunition_type": Constants.PickableType.AR_MAGAZINE, # TO DO: how best to represent this? enum/int/&string/class/instance?
			"max_count": 52, # was: rounds_per_magazine
			"count": 52,
			
			"projectile_type": &"rifle bullet", # type of Projectile created (for fusion pistol the type of projectile created depends on which trigger is fired)
			"burst_count": 0, # 10 for shotgun, 2 for flechette; pretty sure this is no. of Projectiles fired by a single bullet, but need to check if this is added to 1 or is `min(1,burst_count)`
			"theta_error": 7.03125, # projectile's accuracy
			# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
			"dx": 0.0,
			"dz": -0.01953125,
			"recoil_magnitude": 0.0048828125, # applies backward impulse to Player
			#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation
			
			# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
			"ready_ticks": 15 / 60, # (Classic MacOS used 60tick/sec)
			"ticks_per_round": 0 / 60, # null, # TO DO: why is this originally null, not 0?
			"recovery_ticks": 0 / 60,
			"charging_ticks": 0 / 60,
			
			# TO DO: probably just need a single "reload_time" - the other 2 values are for pausing before/after the Classic reload animation but that delay can be built into the weapon animations
			"await_reload_ticks": 10 / 60,
			"loading_ticks": 10 / 60,
			"finish_loading_ticks": 10 / 60,
			#"powerup_ticks": 0, # is always 0 so presumably we don't need it
			
			# TO DO: should we leave illumination to weapon assets? it is, arguably, a gameplay feature: in effect, Player momentarily acts as an omni-/semi-directional light source illuminating both weapon-in-hand model and the local environment (lights up the room); while the WiH glow is a visual effect the environment illumination is a gameplay feature (i.e. user may fire a gun to see in a pitch-black environment) so there is an argument for keeping it here and signalling to Player to emit light flash/emit light directly; OTOH, leaving WeaponInHand to manage the shoot light source (which it currently does) simplifies engine code
			"firing_light_intensity": 0.75,
			"firing_intensity_decay_ticks": 6,
			# TO DO: also allow Color to be specified, e.g. yellowish-white for magnum and AR primary; bluish-white for fusion; saturated orange for flamethrower and alien gun
		},
		
		"secondary_trigger": {
			
			"ammunition_type": Constants.PickableType.AR_GRENADE_MAGAZINE,
			"max_count": 7,
			"count": 7,
			
			
			"projectile_type": &"grenade",
			"burst_count": 0,
			"theta_error": 0.0,
			"dx": 0.0,
			"dz": -0.09765625,
			"recoil_magnitude": 0.0390625,
			
			"ready_ticks": 15 / 60,
			"ticks_per_round": 5 / 60,
			"recovery_ticks": 17 / 60,
			"charging_ticks": 0 / 60,
			"await_reload_ticks": 10 / 60,
			"loading_ticks": 10 / 60,
			"finish_loading_ticks": 10 / 60,
			#"powerup_ticks": 0, # is always 0 so presumably we don't need it
			
			# TO DO: ditto
			"firing_light_intensity": 0.75,
			"firing_intensity_decay_ticks": 6,
		}
	},
]



func _ready() -> void:
	# TO DO: __initialize_xxxx functions can be used to initialize Inventory for new game or to load saved game state
	# for now, there's only 1 weapon defined (index 0), which is for AR
	__initialize_items(ITEM_DEFINITIONS)
	__initialize_weapons(WEAPON_DEFINITIONS)
	current_weapon = __all_weapons[__current_weapon_index]
	current_weapon.activate(true)




# inventory management

var __all_items := []


class InventoryItem:
	
	var item_type:  Constants.PickableType
	var long_name:  String
	var short_name: String
	var max_count:  int
	var count:      int
	
	func configure(data: Dictionary) -> void:
		# external code must treat these properties as read-only
		self.item_type  = data.item_type
		self.long_name  = data.long_name
		self.short_name = data.short_name
		self.max_count  = data.max_count
		self.count      = data.count
	
	func add_item() -> bool:
		if self.count < self.max_count:
			self.count += 1
			return true
		else:
			return false
			
	func remove_item() -> bool:
		if self.count > 0:
			self.count -= 1
			return true
		else:
			return false

func __initialize_items(item_definitions: Array) -> void:
	__all_items.clear()
	var i := 0
	for definition in item_definitions:
		assert(i as Constants.PickableType == definition.item_type)
		i += 1
		var item = InventoryItem.new()
		item.configure(definition)
		__all_items.append(item)


func get_item(item_type: Constants.PickableType) -> InventoryItem:
	return __all_items[int(item_type)]



# weapon management

var __all_weapons := [] # note: Weapon.count indicates if the player is carrying 0, 1, or 2 of each
var __current_weapon_index := 0

var current_weapon: Weapon : get = get_current_weapon # Player has read-only access to this property

func get_current_weapon() -> Weapon:
	return current_weapon


func __initialize_weapons(weapon_states: Array) -> void:
	__all_weapons.clear()
	for state in weapon_states:
		var weapon = Weapon.new()
		weapon.configure(state)
		__all_weapons.append(weapon)


func __switch_weapon(search_func: Callable) -> void:
	var new_weapon = search_func.call()
	if new_weapon != current_weapon:
		# TO DO: fast weapon switching: if user presses PREVIOUS/NEXT key repeatedly, e.g. to switch from SPNKR to Magnum, do not fully cycle through every weapon's draw and holster animations; basically, once user presses PREV/NEXT the first time, start the current weapon's deactivation and, while that is playing, monitor for any additional presses and continue switching; once user stops pressing for, say, 0.2sec, start the next activate animation but allow that animation to be quickly reversed by any additional PREV/NEXT press[es]; rinse and repeat until user makes mind up/a new weapon is brought fully to bear and is ready for use
		current_weapon.deactivate()
		await get_tree().create_timer(current_weapon.ready_ticks).timeout
		current_weapon = new_weapon
		current_weapon.activate()
		await get_tree().create_timer(current_weapon.ready_ticks).timeout


func previous_weapon() -> void:
	var search_func = func():
		while true:
			__current_weapon_index -= 1
			if __current_weapon_index < 0:
				__current_weapon_index = __all_weapons.size() - 1
			var weapon = __all_weapons[__current_weapon_index]
			if weapon.available or weapon == current_weapon:
				return weapon
	__switch_weapon(search_func)


func next_weapon() -> void:
	var search_func = func():
		while true:
			__current_weapon_index += 1
			if __current_weapon_index == __all_weapons.size():
				__current_weapon_index = 0
			var weapon = __all_weapons[__current_weapon_index]
			if weapon.available or weapon == current_weapon:
				return weapon
	__switch_weapon(search_func)


# TO DO: health management goes here? since health has to persist across levels, it can't be stored on per-level Player objects. Define an API here for adding/removing health/oxygen;


