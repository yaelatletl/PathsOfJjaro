extends Node
# global constants and enums


# note: use enums for MRC development (with same names and int values as Classic M2 files, caveat M1-only objects which should be added to enums after the M2 names) as that gives us typechecking
#
# if/when we add 3rd-party modding support, these enums can be changed to ints (TypeIDs), trading GDScript safety for extensibility; similarly, the definition tables can be recreated as external JSONs; the JSONs can also contain dictionaries containing the int-string mappings; a high-level WAD editor can perform consistency checks to ensure JSONs are correctly formed and don't contain any invalid type IDs (but until we develop those authoring tools, GDScript's static typechecker is the most robust option we have, though it's weak on arrays and can't validate dictionary structures)



enum NPCType {
	MARINE,
	TICK_ENERGY,
	TICK_OXYGEN,
	TICK_KAMIKAZE,
	COMPILER_MINOR,
	COMPILER_MAJOR,
	COMPILER_MINOR_INVISIBLE,
	COMPILER_MAJOR_INVISIBLE,
	FIGHTER_MINOR,
	FIGHTER_MAJOR,
	FIGHTER_MINOR_PROJECTILE,
	FIGHTER_MAJOR_PROJECTILE,
	CIVILIAN_CREW, # TO DO: rename these PISTOL_CREW, etc as they are M2's armed Bobs, and use CIVILIAN_CREW for M1's unarmed crew members
	CIVILIAN_SCIENCE,
	CIVILIAN_SECURITY,
	CIVILIAN_ASSIMILATED,
	HUMMER_MINOR,
	HUMMER_MAJOR,
	HUMMER_BIG_MINOR,
	HUMMER_BIG_MAJOR,
	HUMMER_POSSESSED,
	CYBORG_MINOR,
	CYBORG_MAJOR,
	CYBORG_FLAME_MINOR,
	CYBORG_FLAME_MAJOR,
	ENFORCER_MINOR,
	ENFORCER_MAJOR,
	HUNTER_MINOR,
	HUNTER_MAJOR,
	TROOPER_MINOR,
	TROOPER_MAJOR,
	MOTHER_OF_ALL_CYBORGS,
	MOTHER_OF_ALL_HUNTERS,
	SEWAGE_YETI,
	WATER_YETI,
	LAVA_YETI,
	DEFENDER_MINOR,
	DEFENDER_MAJOR,
	JUGGERNAUT_MINOR,
	JUGGERNAUT_MAJOR,
	TINY_FIGHTER,
	TINY_BOB,
	TINY_YETI,
	FUSION_CREW,
	FUSION_SCIENCE,
	FUSION_SECURITY,
	FUSION_ASSIMILATED,
	# TO DO: M1-only types (Hulk, Wasp, Looker, MADD, and Deimos's unarmed crew; we may also add Pfhor crew on Boomer maps, which will be unarmed, unarmored, unmasked Pfhor which normally run away from SO and only use weak teeth and claws for defense when cornered; conversely we can add a few [fairly ineffectual] pistol Bobs to Deimos's Ch2 levels, with some extra Pfhor and scripted scenes so they don't affect the gameplay balance)
}


enum PickableType { # TO DO: can GDScript coerce enums to and from ints?
	NONE = 0, # was FIST; use this for unlimited ammo
	MAGNUM_PISTOL = 1, # in .sce2 files, subtype=1; BUG: MapToJSON has off-by-one error in looking up subtype names (possibly because it omits "Fist"/"Knife" item?), e.g. subtype="Plasma Pistol" should be "Magnum Magazine"
	MAGNUM_MAGAZINE,
	PLASMA_PISTOL,
	PLASMA_ENERGY_CELL,
	ASSAULT_RIFLE,
	AR_MAGAZINE,
	AR_GRENADE_MAGAZINE,
	MISSILE_LAUNCHER,
	MISSILE_2_PACK,
	INVISIBILITY_POWERUP,
	INVINCIBILITY_POWERUP,
	INFRAVISION_POWERUP,
	ALIEN_WEAPON,
	ALIEN_WEAPON_AMMO,
	FLAMETHROWER,
	FLAMETHROWER_CANISTER,
	EXTRAVISION_POWERUP,
	OXYGEN_POWERUP,
	ENERGY_POWERUP_X1,
	ENERGY_POWERUP_X2,
	ENERGY_POWERUP_X3,
	SHOTGUN,
	SHOTGUN_CARTRIDGES,
	SPHT_DOOR_KEY,
	UPLINK_CHIP,
	LIGHT_BLUE_BALL,
	THE_BALL,
	VIOLET_BALL,
	YELLOW_BALL,
	BROWN_BALL,
	ORANGE_BALL,
	BLUE_BALL,
	GREEN_BALL,
	SUBMACHINE_GUN,
	SUBMACHINE_GUN_CLIP,
	# TO DO: M1/MCR items (e.g. DEFENSE_REPAIR_CHIP, ENGINEERING_PASS_KEY)
	FIST,
}


enum ProjectileType {
	ROCKET, # TO DO: is this index 0 or 1? also, what are M1-only types (wasp spit, hulk slap, looker instaboom, any others)? we should append M1-only enums and remap the M1 physics definitions to those new values, which allows us to have a single bestiary for all 3 scenarios
	GRENADE,
	PISTOL_BULLET,
	RIFLE_BULLET,
	SHOTGUN_BULLET,
	STAFF,
	STAFF_BOLT,
	FLAMETHROWER,
	COMPILER_BOLT_MINOR,
	COMPILER_BOLT_MAJOR,
	ALIEN_WEAPON,
	FUSION_BOLT_MINOR,
	FUSION_BOLT_MAJOR,
	HUNTER,
	FIST, # TO DO: rename MINOR_FIST
	ARMAGEDDON_SPHERE,
	ARMAGEDDON_ELECTRICITY,
	JUGGERNAUT_ROCKET,
	TROOPER_BULLET,
	TROOPER_GRENADE,
	MINOR_DEFENDER,
	MAJOR_DEFENDER,
	JUGGERNAUT_MISSILE,
	MINOR_ENERGY_DRAIN,
	MAJOR_ENERGY_DRAIN,
	OXYGEN_DRAIN,
	MINOR_HUMMER,
	MAJOR_HUMMER,
	DURANDAL_HUMMER,
	MINOR_CYBORG_BALL,
	MAJOR_CYBORG_BALL,
	BALL,
	MINOR_FUSION_DISPERSAL,
	MAJOR_FUSION_DISPERSAL,
	OVERLOADED_FUSION_DISPERSAL,
	YETI,
	SEWAGE_YETI,
	LAVA_YETI,
	SMG_BULLET,
	# TO DO: add M1-only hulk slap, wasp spit, looker instaboom, simulacrum instaboom projectile types after the M2 types
	MAJOR_FIST,
}


enum EffectType { # these are visual animations which are played by a projectile when in flight
	ROCKET_CONTRAIL, # TO DO: use M2 int values
	GRENADE_CONTRAIL,
	FLAMETHROWER_BURST, # TO DO: rename FLAMETHROWER_CONTRAIL
}


enum DetonationType { # determines damage type, health delta, shrapnel radius, and animation; TO DO: any other effects?
	ROCKET_EXPLOSION, # TO DO: use M2 int values
	# ROCKET_CONTRAIL,
	GRENADE_EXPLOSION,
	# GRENADE_CONTRAIL,
	BULLET_RICOCHET,
	ALIEN_WEAPON_RICOCHET,
	FLAMETHROWER_BURST, # rename FLAMETHROWER_IMPACT
	FIGHTER_BLOOD_SPLASH,
	PLAYER_BLOOD_SPLASH,
	CIVILIAN_BLOOD_SPLASH,
	ASSIMILATED_CIVILIAN_BLOOD_SPLASH,
	ENFORCER_BLOOD_SPLASH,
	COMPILER_BOLT_MINOR_DETONATION,
	COMPILER_BOLT_MAJOR_DETONATION,
	COMPILER_BOLT_MAJOR_CONTRAIL,
	FIGHTER_PROJECTILE_DETONATION,
	FIGHTER_MELEE_DETONATION,
	HUNTER_PROJECTILE_DETONATION,
	HUNTER_SPARK,
	MINOR_FUSION_DETONATION,
	MAJOR_FUSION_DETONATION,
	# MAJOR_FUSION_CONTRAIL,
	FIST_DETONATION, # TO DO: rename MINOR_FIST_DETONATION,
	MINOR_DEFENDER_DETONATION,
	MAJOR_DEFENDER_DETONATION,
	DEFENDER_SPARK,
	TROOPER_BLOOD_SPLASH,
	# WATER_LAMP_BREAKING, # this effect will be incorporated into breakable scenery's animation
	# LAVA_LAMP_BREAKING,
	# SEWAGE_LAMP_BREAKING,
	# ALIEN_LAMP_BREAKING,
	METALLIC_CLANG,
	# TELEPORT_OBJECT_IN, # how teleport effects are applied to NPCs and PickableItems is TBD (Player will use its own HUD/Viewport animations)
	# TELEPORT_OBJECT_OUT,
	SMALL_WATER_SPLASH,
	MEDIUM_WATER_SPLASH,
	LARGE_WATER_SPLASH,
	LARGE_WATER_EMERGENCE,
	SMALL_LAVA_SPLASH,
	MEDIUM_LAVA_SPLASH,
	LARGE_LAVA_SPLASH,
	LARGE_LAVA_EMERGENCE,
	SMALL_SEWAGE_SPLASH,
	MEDIUM_SEWAGE_SPLASH,
	LARGE_SEWAGE_SPLASH,
	LARGE_SEWAGE_EMERGENCE,
	SMALL_GOO_SPLASH,
	MEDIUM_GOO_SPLASH,
	LARGE_GOO_SPLASH,
	LARGE_GOO_EMERGENCE,
	MINOR_HUMMER_PROJECTILE_DETONATION,
	MAJOR_HUMMER_PROJECTILE_DETONATION,
	DURANDAL_HUMMER_PROJECTILE_DETONATION,
	HUMMER_SPARK,
	CYBORG_PROJECTILE_DETONATION,
	CYBORG_BLOOD_SPLASH,
	MINOR_FUSION_DISPERSAL, # alternate Explosion that does 0 damage when a projectile reaches the end of its lifetime without hitting anything
	MAJOR_FUSION_DISPERSAL, # ditto
	OVERLOADED_FUSION_DISPERSAL, # ditto
	SEWAGE_YETI_BLOOD_SPLASH,
	SEWAGE_YETI_PROJECTILE_DETONATION,
	WATER_YETI_BLOOD_SPLASH,
	LAVA_YETI_BLOOD_SPLASH,
	LAVA_YETI_PROJECTILE_DETONATION,
	YETI_MELEE_DETONATION,
	JUGGERNAUT_SPARK,
	JUGGERNAUT_MISSILE_CONTRAIL,
	SMALL_JJARO_SPLASH,
	MEDIUM_JJARO_SPLASH,
	LARGE_JJARO_SPLASH,
	LARGE_JJARO_EMERGENCE,
	CIVILIAN_FUSION_BLOOD_SPLASH,
	ASSIMILATED_CIVILIAN_FUSION_BLOOD_SPLASH,
	
	# TO DO: M1 detonations
	MAJOR_FIST_DETONATION,
}


enum DamageType { # this determines immunity/weakness flags for each NPCType and the HUD effect animation to display when a projectile or damaging liquid impacts the player (we've split contrails and any other non-detonation effects into separate EffectsType, although Classic had only a single Effects enum for all of them)
	EXPLOSION,
	FIGHTER_STAFF,
	PROJECTILE,
	ABSORBED,
	FLAME,
	HOUND_CLAWS,
	ALIEN_WEAPON,
	HULK_SLAP,
	COMPILER_BOLT,
	FUSION,
	HUNTER_BOLT,
	FIST,
	TELEPORTER,
	DEFENDER,
	YETI_CLAWS,
	YETI_PROJECTILE,
	CRUSHING,
	LAVA, # M2 lava (planetary, volcanic magma); this may be different to M1 lava (liquid rock used as reactor coolant)
	SUFFOCATION,
	GOO,
	ENERGY_DRAIN,
	OXYGEN_DRAIN,
	HUMMER_BOLT,
	SHOTGUN_PROJECTILE,
	# TO DO: M1-only damage types
	
	NONE, # satisfies type checker (we could use `null` = 'no damage' but GDScript lacks an optional type so NONE is the lesser evil; we can reorder DamageType enum later to make its int value `0`); see overload_damage_type
}



# TO DO: use count=-1 to indicate existing InventoryItems' count is not changed; this lets us put item definitions into per-level wad, along with the map and physics

# TO DO: add plural_name (pluralized long_name, e.g. Magnum Pistols)
const ITEM_DEFINITIONS := [ # for now, this array is ordered same as PickableType enum and M2 map data, so we can convert map JSONs to PickableItems
	# TO DO: fix/finish max_counts, counts, short_name, plural_[long_]name
	# note: while keys could be shorter, it's best to keep them same as identifiers used in the code
	{"item_type": PickableType.FIST,                  "long_name": "Fist",                  "short_name": "FIST", "max_count":  2, "count":  2},
	{"item_type": PickableType.MAGNUM_PISTOL,         "long_name": ".44 Magnum Pistol",     "short_name": "MA44", "max_count":  2, "count":  2},
	{"item_type": PickableType.MAGNUM_MAGAZINE,       "long_name": ".44 Magnum Magazine",   "short_name": "MG44", "max_count": 50, "count":  3},
	{"item_type": PickableType.PLASMA_PISTOL,         "long_name": "Plasma Pistol",         "short_name": "ZEUS", "max_count":  1, "count":  0},
	{"item_type": PickableType.PLASMA_ENERGY_CELL,    "long_name": "Plasma Energy Cell",    "short_name": "MGZS", "max_count":  1, "count":  0},
	{"item_type": PickableType.ASSAULT_RIFLE,         "long_name": "MA75 Assault Rifle",    "short_name": "AR75", "max_count": 15, "count":  1},
	{"item_type": PickableType.AR_MAGAZINE,           "long_name": "AR Magazine",           "short_name": "MG75", "max_count":  8, "count":  4},
	{"item_type": PickableType.AR_GRENADE_MAGAZINE,   "long_name": "AR Grenade Magazine",   "short_name": "MGGR", "max_count":  1, "count":  2},
	{"item_type": PickableType.MISSILE_LAUNCHER,      "long_name": "Missile Launcher",      "short_name": "SPNK", "max_count":  1, "count":  0},
	{"item_type": PickableType.MISSILE_2_PACK,        "long_name": "Missile 2-Pack",        "short_name": "MGSP", "max_count":  1, "count":  0},
	{"item_type": PickableType.INVISIBILITY_POWERUP,  "long_name": "Invisibility Powerup",  "short_name": "",     "max_count":  2, "count":  0},
	{"item_type": PickableType.INVINCIBILITY_POWERUP, "long_name": "Invincibility Powerup", "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.INFRAVISION_POWERUP,   "long_name": "Infravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ALIEN_WEAPON,          "long_name": "Alien Weapon",          "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ALIEN_WEAPON_AMMO,     "long_name": "Alien Weapon Ammo",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.FLAMETHROWER,          "long_name": "Flamethrower",          "short_name": "TOZT", "max_count":  1, "count":  0},
	{"item_type": PickableType.FLAMETHROWER_CANISTER, "long_name": "Flamethrower Canister", "short_name": "MGTZ", "max_count":  1, "count":  0},
	{"item_type": PickableType.EXTRAVISION_POWERUP,   "long_name": "Extravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.OXYGEN_POWERUP,        "long_name": "Oxygen Powerup",        "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ENERGY_POWERUP_X1,     "long_name": "Energy Powerup x1",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ENERGY_POWERUP_X2,     "long_name": "Energy Powerup x2",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ENERGY_POWERUP_X3,     "long_name": "Energy Powerup x3",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.SHOTGUN,               "long_name": "Shotgun",               "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.SHOTGUN_CARTRIDGES,    "long_name": "Shotgun Cartridges",    "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.SPHT_DOOR_KEY,         "long_name": "S'pht Door Key",        "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.UPLINK_CHIP,           "long_name": "Uplink Chip",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.LIGHT_BLUE_BALL,       "long_name": "Light Blue Ball",       "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.THE_BALL,              "long_name": "The Ball",              "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.VIOLET_BALL,           "long_name": "Violet Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.YELLOW_BALL,           "long_name": "Yellow Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.BROWN_BALL,            "long_name": "Brown Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ORANGE_BALL,           "long_name": "Orange Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.BLUE_BALL,             "long_name": "Blue Ball",             "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.GREEN_BALL,            "long_name": "Green Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.SUBMACHINE_GUN,        "long_name": "Submachine Gun",        "short_name": "FSSM", "max_count":  1, "count":  0},
	{"item_type": PickableType.SUBMACHINE_GUN_CLIP,   "long_name": "Submachine Gun Clip",   "short_name": "MGFS", "max_count":  1, "count":  0},
	# TO DO: add M1/MCR item types (e.g. PASS_KEY, SECURITY_REPAIR_CHIP)
	{"item_type": PickableType.NONE,                  "long_name": "",                      "short_name": "",     "max_count": -1, "count": -1}, # TO DO: fix/finish counts, max_counts, short_name
]



const PROJECTILE_DEFINITIONS := [
	
]



const DETONATION_DEFINITIONS := [
	
]



const EFFECT_DEFINITONS := [
	
]

# liquid stops most projectiles; fusion instantly detonates on liquid impact, dealing player damage (minor: 30±10, major: 80±20; I suspect both triggers may do shrapnel damage underwater but would need to test) - how does fusion know to do instant damage - is it hardcoded? (there is no obvious flag for this)

# final M1 weapon order should be: fist, magnum, fusion, AR, alien gun, flamethrower, rocket launcher; this ensures that when alien gun/flamethrower runs empty, the Player switches to less powerful, more general-purpose weapon (typically AR) and avoids Classic's annoying flaw of auto-switching from alien gun to SPNKR (very dangerous!)


const WEAPON_DEFINITIONS := [ # TO DO: add remaining definitions in order of previous/next weapon switching (Arrival Demo requires FIST, MAGNUM_PISTOL, and ASSAULT_RIFLE; the rest can be added later)
{
		"item_type": PickableType.FIST,
		#"weapon_class": "melee", # how does this influence weapon behaviors? (e.g. I think melee affects run-punch damage; what else?)
		
		"activation_time": 0.117,
		"deactivation_time": 0.117,
		
		"flags": {
			"is_automatic": false, # TO DO: check AO code for behavior; all Classic weapons are automatic, except possibly SPNKR, as holding a trigger repeats firing (a true semi-automatic requires a fresh trigger pull for each shot - holding the trigger would only shoot once)
			
			"fires_out_of_phase": false, # allows one pistol to fire before other finishes its firing animation
			"reloads_out_of_phase": false, # was reloads_in_one_hand`; allows one shotgun to reload before the other finishes its firing animation (TO DO: if both shotguns require reloading, should they reload one at a time before either starts firing? or can the first reload and then start firing as the second reloads?)
			"triggers_share_magazine": false, # was `triggers_share_ammo`
			
			"fires_under_media": true,
			"fires_in_vacuum": true, # added
			
			"has_random_ammo_on_pickup": false,
			"disappears_after_use": false,
			#"secondary_has_angular_flipping": false,
		},
		
		"primary_trigger": {
			"item_type": PickableType.NONE,
			"max_count": 1,
			"count": 1,
			
			"projectile_type": ProjectileType.FIST,
			"sprint_projectile_type": ProjectileType.FIST,
			"ammo_consumption": 0,
			"projectile_count": 1,
			"theta_error": 0.0,
			"origin_delta": [0.0, -0.09765625, 0.3],
			
			"recoil_magnitude": 0.0,
			
			"time_per_round": 0.0,
			"recovery_time": 0.167,
			"charging_time": 0.0,
			"overloading_time": 0.0,
			"overload_damage_type": DamageType.NONE,
			"reloading_time": 0.0,
		},
		"secondary_trigger": {
			"item_type": PickableType.NONE,
			"max_count": 1,
			"count": 1,
			
			"projectile_type": ProjectileType.FIST,
			"sprint_projectile_type": ProjectileType.FIST,
			"ammo_consumption": 0,
			"projectile_count": 1,
			"theta_error": 0.0,
			"origin_delta": [0.0, -0.09765625, 0.3],
			
			"recoil_magnitude": 0.0,
			
			"time_per_round": 0.0,
			"recovery_time": 0.167,
			"charging_time": 0.0,
			"reloading_time": 0.0,
		}
	},
	
	{
		"item_type": PickableType.MAGNUM_PISTOL,
		#"weapon_class": "dual wield",
		
		"activation_time": 0.167,
		"deactivation_time": 0.167,
		
		"flags": {
			"is_automatic": false,
			
			"fires_out_of_phase": true,# allows one pistol to start firing before other finishes its firing animation; in effect this shortens the delay between repeat firing so it's shorter than the firing anination; we should be able to handle the overlap in WIH by defining left/right/both firing loops where the 'both' loop starts and ends on one hand about to fire while the other is 50% through its own 'fire-then-rest' cycle; we can then freely switch between 1- and 2- handed firing animations at the appropriate time indexes; alternatively, we might subclass AnimationPlayer with `@export hand_path` so we can set up a single hand's animations then duplicate that player so we have one player for each hand, and both can run singly or synchronized
			"reloads_out_of_phase": false,
			"triggers_share_magazine": false,
			
			"fires_under_media": false,
			"fires_in_vacuum": false,
			
			"has_random_ammo_on_pickup": false,
			"disappears_after_use": false,
			#"secondary_has_angular_flipping": false,
		},
		
		"ready_ticks": 0.167,
		"await_reload_ticks": 0.083,
		"loading_ticks": 0.083,
		"finish_loading_ticks": 0.083,
		"powerup_ticks": 0,
		"primary_trigger": {
			"item_type": PickableType.MAGNUM_MAGAZINE,
			"max_count": 8,
			"count": 8,
			
			"projectile_type": ProjectileType.PISTOL_BULLET,
			"sprint_projectile_type": ProjectileType.PISTOL_BULLET,
			"ammo_consumption": 1,
			"projectile_count": 1,
			"theta_error": 0.703125,
			"origin_delta": [-0.041015625, -0.01953125, 0.3], # TO DO: update WU
			
			"recoil_magnitude": 0.009765625,
			"time_per_round": 0.0,
			"recovery_time": 0.167,
			"charging_time": 0.0,
			"overloading_time": 0.0,
			"overload_damage_type": DamageType.NONE,
			"reloading_time": 0.0,
		},
		"secondary_trigger": {
			"item_type": PickableType.MAGNUM_MAGAZINE,
			"max_count": 8,
			"count": 8,
			
			"projectile_type": ProjectileType.PISTOL_BULLET,
			"sprint_projectile_type": ProjectileType.PISTOL_BULLET,
			"ammo_consumption": 1,
			"projectile_count": 1,
			"theta_error": 0.703125,
			"origin_delta": [0.041015625, -0.01953125, 0.3], # TO DO: update WU
			
			"recoil_magnitude": 0.009765625,
			
			"time_per_round": 0.0,
			"recovery_time": 0.167,
			"charging_time": 0.0,
			"overloading_time": 0.0,
			"overload_damage_type": DamageType.NONE,
			"reloading_time": 0.0,
		}
	},
	
	{
		"item_type": PickableType.ASSAULT_RIFLE,
		#"long_name": "MA75B Assault Rifle", # show this in Inventory overlay
		#"short_name": "MA75B", # show this in HUD
		#"max_count": 1,
		#"count": 1,
		#"powerup_type": null,
		#"weapon_class": "multipurpose", # how does this influence weapon behaviors? (e.g. I think melee affects run-punch damage; what else?)
		
		"activation_time": 0.25, # (Classic MacOS used 60tick/sec) # TO DO: rename 'ticks' to 'time' in all weapon definitions and convert values to seconds (divide ticks by 60)
		"deactivation_time": 0.25,
		
		"flags": {
			"is_automatic": true, # true for AR, SPNKR, flamethrower, alien gun, flechette gun; not sure what it does though as other weapons also fire repeatedly when trigger key is held down
			"triggers_share_magazine": false, # true for fusion pistol and alien gun, false for others; if true, both triggers share the same Magazine instance, else each trigger receives its own Magazine instance when Weapon is configured
			
			"fires_out_of_phase": false, # true for pistol; allows one pistol to start firing before other finishes its firing animation; probably best expressed as a `time_before_switching_trigger` float and move on both triggers which is normally 0 but can be +ve or -ve to control the interlock between end of one hand firing and start of other
			"reloads_out_of_phase": false, # true for shotgun; should this move to triggers too?
			
			"fires_under_media": false, # true for fists, fusion pistol, flechette gun (note that firing fusion underwater causes radius damage, though not sure if this is the Projectile or Weapon which does this; Q. does firing fusion into water also do radius damage to nearby bodies in the water, or does fusion blowback only occur when weapon itself is submerged?)
			"fires_in_vacuum": false, # does exactly what it says; in addition to G4 Sunbathing, we might turn some short sections of maps into vacuum to vary gameplay a bit more: vacuum forces user to abandon AR and switch to fist and fusion, and optionally change tactics to evade instead of kill where possible (note: we don't want to change gameplay too much though, so oxygen chargers should be provided so user is at little risk of suffocation outside of G4 where this is a gameplay feature)
			
			"has_random_ammo_on_pickup": false, # true for alien gun; note pickable ammo objects *always* have full ammo (); while some games randomize the number of rounds per ammo box and track the total number of bullets in inventory, allowing weapon to be manually reloaded at any time, we will stick to the Classic Marathon behavior here (in future, if other games use this engine then this can all be made configurable, but for now we only implement the features MCR requires, not features it doesn't)
			"disappears_after_use": false, # true for alien gun
			#"plays_instant_shell_casing_sound": false, # always false
			#"powerup_is_temporary": false, # always false
			"secondary_has_angular_flipping": false, # true for alien gun, TO DO: move this onto triggers and replace with options for specifying spread behavior: probably make it an array of [[x,y],...] which is the angles at which repeating shots fire when trigger is held; we'll set up single projectile as primary trigger and 3-way spread as secondary trigger (there's no benefit to Classic's trigger behaviors where secondary is useless on its own and both triggers must be held for full spread), making alien gun a dual-mode weapon same as fusion
		},
		
		# TO DO: move these settings to WeaponInHand's shooting and reloading animations
		#"idle_height": 1.1666565,
		#"bob_amplitude": 0.028564453,
		#"idle_width": 0.5,
		#"horizontal_amplitude": 0.0,
		#"kick_height": 0.0625, # presumably M2 WU
		#"reload_height": 0.75,
		
		"primary_trigger": {
			"item_type": PickableType.AR_MAGAZINE,
			"max_count": 5, # was: rounds_per_magazine
			"count": 5,
			
			"projectile_type": ProjectileType.RIFLE_BULLET,
			"sprint_projectile_type": ProjectileType.MAJOR_FIST,
			
			# note: these 2 properties replace Classic's confusing weapon settings, where fusion and alien gun primary and secondary triggers' rounds_per_magazine and burst_count bore little resemblance to what actually got fired per trigger pull (I suspect the secondary trigger's increased consumption was hardcoded to the `overload` flag as only fusion actually seems to do it)
			"ammo_consumption": 1, 
			"projectile_count": 1, # 10 for shotgun, 2 for flechette
			
			"theta_error": 7.03125, # projectile's accuracy
			# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
			#"dx": 0.0,
			#"dz": -0.01953125,
			"origin_delta": [0.0, -0.01953125, 0.3], # TO DO: I’m guessing what Classic calls dz is the y-axis offset, which I'm guessing is relative to center of camera; also ensure projectile always originate *inside* the Player's capsule body, never outside it, as we don't want projectiles originating inside walls or scenery when squeezing along tight service corridors
			
			"recoil_magnitude": 0.0048828125, # applies backward impulse to Player
			#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation
			
			# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
			"time_per_round": 0.0, # null, # TO DO: why is this originally null, not 0? presumably this is delay before firing animation plays, with Shapes' animation key frame triggering projectile dispatch, and recovery_time as delay after end of sequence before next [firing?] sequence can play. 
			"recovery_time": 0.0,
			"charging_time": 0.0, # time before trigger can fire, but wait until trigger key is released to dispatch
			"overloading_time": 0.0, # if charging_time>0, the delay before the weapon explodes (0=never explode)
			"overload_damage_type": DamageType.NONE, # if overloading_time>0, the type and size of explosion
			"reloading_time": 0.5, # this is "await_reload_ticks":10 + "loading_ticks":10 + "finish_loading_ticks":10 as the WIH animation can provide the visual pauses; the only reason we might want a separate await_reload_time is to allow the player to preempt auto-reloading by immediately switching to another weapon before the reloading sequence starts, but let's KISS for now; also, check if this is the total reload time or if the animation sequence duration is also counted
			#"powerup_time": 0, # is always 0 so presumably we don't need it
			
			# TO DO: for now, let's leave firing illumination to weapon assets; it is, arguably, a gameplay feature: in effect, Player momentarily acts as an omni-/semi-directional light source illuminating both weapon-in-hand model and the local environment (lights up the room); while the WiH glow is a visual effect the environment illumination is a gameplay feature (i.e. user may fire a gun to see in a pitch-black environment) so there is an argument for keeping it here and signalling to Player to emit light flash/emit light directly; OTOH, leaving WeaponInHand to manage the shoot light source (which it currently does) simplifies engine code and it ensures the light emits at the front of the barrel (the light might also be semi-directional, with most of the light being thrown forward; remember too that grenade, rocket, M2-style alien gun, and flamethrower projectiles are also light sources)
			
			#"firing_light_intensity": 0.75,
			#"firing_intensity_decay_time": 6,
			# TO DO: also allow Color to be specified, e.g. yellowish-white for magnum and AR primary; bluish-white for fusion; saturated orange for flamethrower and alien gun
		},
		
		"secondary_trigger": {
			
			"item_type": PickableType.AR_GRENADE_MAGAZINE,
			"max_count": 7,
			"count": 7,
			
			"projectile_type": ProjectileType.GRENADE,
			"sprint_projectile_type": ProjectileType.MAJOR_FIST,
			
			"ammo_consumption": 1,
			"projectile_count": 1,
			
			"theta_error": 0.0,
			#"dx": 0.0,
			#"dz": -0.09765625,
			"origin_delta": [0.0, -0.09765625, 0.3],
			"recoil_magnitude": 0.0390625,
			
			"time_per_round": 5 / 60,
			"recovery_time": 17 / 60,
			"charging_time": 0.0,
			"overloading_time": 0.0,
			"overload_damage_type": DamageType.NONE,
			"reloading_time": 0.5,
			#"powerup_ticks": 0, # is always 0 so presumably we don't need it
			
			# TO DO: as above
			#"firing_light_intensity": 0.75,
			#"firing_intensity_decay_ticks": 6,
		}
	},
]

