extends Node
# global constants and enums


# note: use enums for MRC development (with same names and int values as Classic M2 files, caveat M1-only objects which should be added to enums after the M2 names) as that gives us typechecking; if/when adding future 3rd-party modding support these can be changed to ints, trading GDScript safety for extensibility (the wad could either define its own .gd enums which the engine internally casts to ints for its own use or JSON strings which the wad packer can convert to ints after checking all string names are valid)


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
	FIST = 0, # TO DO: can we omit this?
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
	FIST,
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
}


enum EffectType { # these are visual animations which are played by a projectile when in flight
	ROCKET_CONTRAIL, # TO DO: use M2 int values
	GRENADE_CONTRAIL,
	FLAMETHROWER_BURST, # TO DO: rename FLAMETHROWER_CONTRAIL
}


enum DetonationType { # TO DO: rename DetonationType?
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
	FIST_DETONATION,
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
}


enum DamageType { # this determines the HUD effect animation to display when a projectile or damaging liquid impacts the player
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
}




const ITEM_DEFINITIONS := [ # for now, this array is ordered same as PickableType enum and M2 map data, so we can convert map JSONs to PickableItems
	{"item_type": PickableType.FIST,                  "long_name": "Fist",                  "short_name": "",     "max_count":  2, "count":  2}, # TO DO: fix/finish counts, max_counts, short_name
	{"item_type": PickableType.MAGNUM_PISTOL,         "long_name": "Magnum Pistol",         "short_name": "",     "max_count":  2, "count":  1},
	{"item_type": PickableType.MAGNUM_MAGAZINE,       "long_name": "Magnum Magazine",       "short_name": "MEGA", "max_count": 50, "count":  7},
	{"item_type": PickableType.PLASMA_PISTOL,         "long_name": "Plasma Pistol",         "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.PLASMA_ENERGY_CELL,    "long_name": "Plasma Energy Cell",    "short_name": "ZEUS", "max_count":  1, "count":  0},
	{"item_type": PickableType.ASSAULT_RIFLE,         "long_name": "Assault Rifle",         "short_name": "",     "max_count": 15, "count":  1},
	{"item_type": PickableType.AR_MAGAZINE,           "long_name": "AR Magazine",           "short_name": "MA75", "max_count":  8, "count":  4},
	{"item_type": PickableType.AR_GRENADE_MAGAZINE,   "long_name": "AR Grenade Magazine",   "short_name": "GREN", "max_count":  1, "count":  2},
	{"item_type": PickableType.MISSILE_LAUNCHER,      "long_name": "Missile Launcher",      "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.MISSILE_2_PACK,        "long_name": "Missile 2-Pack",        "short_name": "SSM",  "max_count":  1, "count":  0},
	{"item_type": PickableType.INVISIBILITY_POWERUP,  "long_name": "Invisibility Powerup",  "short_name": "",     "max_count":  2, "count":  0},
	{"item_type": PickableType.INVINCIBILITY_POWERUP, "long_name": "Invincibility Powerup", "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.INFRAVISION_POWERUP,   "long_name": "Infravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ALIEN_WEAPON,          "long_name": "Alien Weapon",          "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.ALIEN_WEAPON_AMMO,     "long_name": "Alien Weapon Ammo",     "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.FLAMETHROWER,          "long_name": "Flamethrower",          "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.FLAMETHROWER_CANISTER, "long_name": "Flamethrower Canister", "short_name": "TOZT", "max_count":  1, "count":  0},
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
	{"item_type": PickableType.SUBMACHINE_GUN,        "long_name": "Submachine Gun",        "short_name": "",     "max_count":  1, "count":  0},
	{"item_type": PickableType.SUBMACHINE_GUN_CLIP,   "long_name": "Submachine Gun Clip",   "short_name": "",     "max_count":  1, "count":  0},
	# TO DO: add M1/MCR item types (e.g. PASS_KEY, SECURITY_REPAIR_CHIP)
]






const WEAPON_DEFINITIONS := [
	# TO DO: get AR working correctly, then add remaining weapon definitions here
	
	# final M1 weapon order should be: fist, magnum, fusion, AR, alien gun, flamethrower, rocket launcher; this ensures that when alien gun/flamethrower runs empty, the Player switches to less powerful, more general-purpose weapon (typically AR) and avoids Classic's annoying flaw of auto-switching from alien gun to SPNKR (very dangerous!)
	{
		
		"long_name": "MA75B Assault Rifle", # show this in Inventory overlay
		"short_name": "MA75B", # show this in HUD
		
		"max_count": 1,
		"count": 1, # 1 for testing; normally 0 for everything except fist (2) and pistol (1)
		
		"item_type": PickableType.ASSAULT_RIFLE,
		
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
			
			"ammunition_type": PickableType.AR_MAGAZINE, # TO DO: how best to represent this? enum/int/&string/class/instance?
			"max_count": 5, # was: rounds_per_magazine
			"count": 5,
			
			"projectile_type": ProjectileType.RIFLE_BULLET,
			"burst_count": 0, # 10 for shotgun, 2 for flechette; pretty sure this is no. of Projectiles fired by a single bullet, but need to check if this is added to 1 or is `min(1,burst_count)`
			"theta_error": 7.03125, # projectile's accuracy
			# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
			#"dx": 0.0,
			#"dz": -0.01953125,
			"origin_delta": [0.0, -0.01953125, 0.3], # TO DO: I’m guessing what Classic calls dz is the y-axis offset, which I'm guessing is relative to center of camera; also ensure projectile always originate *inside* the Player's capsule body, never outside it, as we don't want projectiles originating inside walls or scenery when squeezing along tight service corridors
			
			"recoil_magnitude": 0.0048828125, # applies backward impulse to Player
			#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation
			
			# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
			"ready_time": 0.25, # (Classic MacOS used 60tick/sec) # TO DO: rename 'ticks' to 'time' in all weapon definitions and convert values to seconds (divide ticks by 60)
			"time_per_round": 0.0, # null, # TO DO: why is this originally null, not 0?
			"recovery_time": 0.0,
			"charging_time": 0.0,
			"reloading_time": 0.5, # this is "await_reload_ticks":10 + "loading_ticks":10 + "finish_loading_ticks":10 as the WIH animation can provide the visual pauses; the only reason we might want a separate await_reload_time is to allow the player to preempt auto-reloading by immediately switching to another weapon before the reloading sequence starts, but let's KISS for now
			#"powerup_time": 0, # is always 0 so presumably we don't need it
			
			# TO DO: for now, let's leave firing illumination to weapon assets; it is, arguably, a gameplay feature: in effect, Player momentarily acts as an omni-/semi-directional light source illuminating both weapon-in-hand model and the local environment (lights up the room); while the WiH glow is a visual effect the environment illumination is a gameplay feature (i.e. user may fire a gun to see in a pitch-black environment) so there is an argument for keeping it here and signalling to Player to emit light flash/emit light directly; OTOH, leaving WeaponInHand to manage the shoot light source (which it currently does) simplifies engine code and it ensures the light emits at the front of the barrel (the light might also be semi-directional, with most of the light being thrown forward; remember too that grenade, rocket, M2-style alien gun, and flamethrower projectiles are also light sources)
			
			#"firing_light_intensity": 0.75,
			#"firing_intensity_decay_time": 6,
			# TO DO: also allow Color to be specified, e.g. yellowish-white for magnum and AR primary; bluish-white for fusion; saturated orange for flamethrower and alien gun
		},
		
		"secondary_trigger": {
			
			"ammunition_type": PickableType.AR_GRENADE_MAGAZINE,
			"max_count": 7,
			"count": 7,
			
			
			"projectile_type": ProjectileType.GRENADE,
			"burst_count": 0,
			"theta_error": 0.0,
			#"dx": 0.0,
			#"dz": -0.09765625,
			"origin_delta": [0.0, -0.09765625, 0.3],
			"recoil_magnitude": 0.0390625,
			
			"ready_time": 0.25,
			"time_per_round": 5 / 60,
			"recovery_time": 17 / 60,
			"charging_time": 0.0,
			"reloading_time": 0.5,
			#"powerup_ticks": 0, # is always 0 so presumably we don't need it
			
			# TO DO: as above
			#"firing_light_intensity": 0.75,
			#"firing_intensity_decay_ticks": 6,
		}
	},
]

