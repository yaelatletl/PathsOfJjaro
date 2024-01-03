extends Node


# TODO: weapon and other Classic Physics are currently defined as TYPEDefinitions.gd; once the final data structures are decided on, they can be replaced with external .json files, but for development this is quickest; the only proviso is that (except for enum literals) definitions should use JSON-compatible types only


# final M1 weapon order should be: fist, magnum, fusion, AR, alien gun, flamethrower, rocket launcher; this ensures that when alien gun/flamethrower runs empty, the Player switches to less powerful, more general-purpose weapon (typically AR) and avoids Classic's annoying flaw of auto-switching from alien gun to SPNKR (very dangerous!)


# note: these currently use timings appropriate for the greybox weapon animations; setting final timings to replicate M2 can be done later


# caution: if rounds_per_shot > 1, it must be possible to deplete that magazine or it will never reload


const WEAPON_DEFINITIONS := [ # TODO: add remaining definitions in order of previous/next weapon switching (Arrival Demo requires FIST, MAGNUM_PISTOL, and ASSAULT_RIFLE; the rest can be added later)
	{
		"pickable_type": Enums.PickableType.FIST, # == Enums.WeaponType.FIST
		"weapon_class": "FistWeapon", # for now, these names are defined in a hardcoded lookup table in WeaponManager; eventually that table should be populated dynamically
		
		"activating_time":   0.25,
		"deactivating_time": 0.25,
		
		#"is_automatic": false, # true for AR, TOZT, alien gun, SMG; what is not clear is why it is needed since all weapons repeat-fire as long as trigger is held # TODO: check AO code for behavior; all Classic weapons are automatic, except possibly SPNKR, as holding a trigger repeats firing (semi-automatic would require a fresh trigger pull for each shot)
		
		"triggers_shoot_independently": false, # allows one pistol to fire before other finishes its firing animation
		#"triggers_reload_independently": false, # was triggers_reload_independently`; allows one shotgun to reload before the other finishes its firing animation (TODO: if both shotguns require reloading, should they reload one at a time before either starts firing? or can the first reload and then start firing as the second reloads?)
		"triggers_share_magazine": false, # was `triggers_share_ammo`; true for fusion and alien gun, false for AR and other weapons
		"disappears_when_empty": false, # true for alien gun
		
		"primary_trigger": {
			"pickable_type":  Enums.PickableType.FIST,
			"max_count": 1, # number of rounds the trigger's magazine can hold
			"count":     1, # number of rounds currently in the trigger's magazine
			
			"projectile_type":      Enums.ProjectileType.MINOR_FIST,
			"rounds_per_shot":      0,
			"projectiles_per_shot": 1,
			"theta_error":          0.0,
			"origin_delta":         [0.0, -0.09765625, 0.3],
			"angular_spread":       null,
			"recoil_magnitude":     0.0,
			
			"shooting_time":  0.33, # the time it takes to play the primary shooting animation (animations must not be longer than these times or they will clip)
			"reloading_time": 0.0,  # the time it takes to play the primary reloading animation
			"empty_time":     0.25, # the time it takes to play the primary empty (trigger clicked) animation
			
			# not yet implemented; used by fusion
			"charging_time":    0.0,
			"overloading_time": 0.0,
			"overload_damage_type": Enums.DamageType.NONE,
		},
		
		"secondary_trigger": { # sprint-punch
			"pickable_type": Enums.PickableType.FIST,
			"max_count": 1,
			"count": 1,
			
			"projectile_type":      Enums.ProjectileType.MAJOR_FIST,
			"rounds_per_shot":      0,
			"projectiles_per_shot": 1,
			"origin_delta":         [0.0, -0.09765625, 0.3],
			"theta_error":          0.0,
			"angular_spread":       null,
			"recoil_magnitude":     0.0,
			
			"shooting_time":        0.33,
			"reloading_time":       0.0,
			"empty_time":           0.25,
			"charging_time":        0.0,
			"overloading_time":     0.0,
			
			"overload_damage_type": Enums.DamageType.NONE,
		},
	},
	
	
	{
		"pickable_type":     Enums.PickableType.MAGNUM_PISTOL,
		"weapon_class":      "DualWieldWeapon",
		
		"activating_time":   0.5,
		"deactivating_time": 0.5,
		
		"triggers_shoot_independently":  false,
		#"triggers_reload_independently": false,
		"triggers_share_magazine":       false,
		"disappears_when_empty":         false,
		
		"primary_trigger": {
			"pickable_type":        Enums.PickableType.MAGNUM_MAGAZINE,
			"max_count":            8,
			"count":                8,
			
			"projectile_type":      Enums.ProjectileType.PISTOL_BULLET,
			"rounds_per_shot":      1,
			"projectiles_per_shot": 1,
			"origin_delta":         [-0.041015625, -0.01953125, 0.3],
			"theta_error":          0.703125,
			"angular_spread":       null,
			"recoil_magnitude":     0.009765625,
			
			"shooting_time":        0.5,
			"reloading_time":       1.5,
			"empty_time":           0.25,
			"charging_time":        0.0,
			"overloading_time":     0.0,
			"overload_damage_type": Enums.DamageType.NONE,
			
		},
		"secondary_trigger": null,
	},
	
	
	{
		"pickable_type":     Enums.PickableType.ASSAULT_RIFLE,
		"weapon_class":      "DualPurposeWeapon",
		
		"activating_time":   0.5, # timings are in seconds (Classic used ticks = 1/60sec)
		"deactivating_time": 0.5,
		
		"triggers_shoot_independently":  true, # true for AR
		#"triggers_reload_independently": false, # true for shotgun
		"triggers_share_magazine":       false, # true for fusion pistol and alien gun; if true, both triggers share one Magazine instance, else each trigger gets its own Magazine instance
		"disappears_when_empty":         false,
		
		"primary_trigger": {
			"pickable_type":        Enums.PickableType.AR_MAGAZINE,
			"max_count":            52,
			"count":                52, # for random ammo on pickup, use -ve count
			
			"projectile_type":      Enums.ProjectileType.RIFLE_BULLET,
			"rounds_per_shot":      1, # how many rounds this trigger consumes per shot; this is usually 1
			"projectiles_per_shot": 1, # how many projectiles this trigger spawns per shot; 10 for shotgun, 2 for flechette, 1 for everything else
			"origin_delta":         [0.0, -0.01953125, 0.3], # offset from Player's center to Projectile's origin; important: a projectile MUST spawn inside the Player's capsule body, never outside it, as we don't want projectiles originating inside walls or scenery when player is in tight service corridors; TODO: this is M2 units - update to Godot units
			
			"theta_error":          7.03125, # projectile's accuracy; TODO: this is M2 units - update to Godot units
			"angular_spread":       null, # for alien gun, secondary_trigger's fires projectiles in a 3-way spread, so this property will be e.g. [Vector2(0,0), Vector2(-0.3,0), Vector(0.3,0)] - pressing and holding the trigger fires first projectile straight, second to its left, third to its right, repeating the cycle until trigger is released (this replaces Classic's behavior where secondary fired 2-way only and both keys had to be held to get 3-way)
			"recoil_magnitude":     0.0048828125, # applies backward impulse to Player; TODO: this is M2 units - update to Godot units
			
			# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
			"shooting_time":        0.18,
			"reloading_time":       1.5,
			"empty_time":           0.25, # trigger clicked animation
			"charging_time":        0.0, # time before trigger can fire, but wait until trigger key is released to dispatch
			"overloading_time":     0.0, # if charging_time>0, the delay before the weapon explodes (0=never explode)
			
			"overload_damage_type": Enums.DamageType.NONE, # if overloading_time>0, the type and size of explosion
		},
		
		"secondary_trigger": { # normally null for single-wield single-mode weapons (TOZT, SPNKR, SMG); if null, both __primary_trigger_data and __secondary_trigger_data are set to the primary_trigger definition
			"pickable_type":        Enums.PickableType.AR_GRENADE_MAGAZINE,
			"max_count":            7,
			"count":                7,
			
			"projectile_type":      Enums.ProjectileType.GRENADE,
			"rounds_per_shot":      1,
			"projectiles_per_shot": 1,
			"origin_delta":         [0.0, -0.09765625, 0.3],
			"theta_error":          0.0,
			"angular_spread":       null,
			"recoil_magnitude":     0.0390625,
			
			"shooting_time":        0.8,
			"reloading_time":       1.5,
			"empty_time":           0.25,
			"charging_time":        0.0,
			"overloading_time":     0.0,
			
			"overload_damage_type": Enums.DamageType.NONE,
		}
	},
]

