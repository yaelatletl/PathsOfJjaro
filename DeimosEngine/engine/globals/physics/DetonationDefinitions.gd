extends Node



const DETONATION_DEFINITIONS := [ # originally Physics Effects, but we've separated visual-only effects from detonations
	
	{
		"detonation_type": Enums.DetonationType.PISTOL_BULLET_DETONATION,
		"name": "bullet explosion",
		"area_of_effect": 0.0,
		"damage_type": Enums.DamageType.PROJECTILE,
		"base": 20,
		"random": 8,
		"scale": 0.0,
		"delay": 0,
		"delay_sound": null,
	},
	
	{
		"detonation_type": Enums.DetonationType.GRENADE_EXPLOSION, # once these data structures move to external JSON, auto-generate an int (array index or GUID?) for all types; use the "name" property in JSON to identify both the .tscn and a definition's relationships to other definitions (we currently use enums for relationships as that has better typechecking)
		"name": "grenade explosion", # TO DO: naming conversion for mapping human-readable names to scene names/panes (simplest is just to insert the definition type and definition name strings into "res://assets/%s/%s.tscn" after validating strings, e.g. "res://assets/detonations/grenade explosion.tscn", although we could convert names to e.g. "GrenadeExplosion.tscn" if TitleCase works better)
		# bear in mind that we can pack the final WAD data into binary form for efficient loading, though writing data to .ini/.json is advantageous for git and interchange with other tools (still, we might end up using .ini for our uncompiled data files as Godot prefers .ini for its own data and has greater serialization support)
		#"flags": {
		#	"end_when_animation_loops": true, # usually true; false for melee projectiles, probably because they have no animation; can probably get rid of it
		#	"end_when_transfer_animation_loops": false, # ditto
		#	"sound_only": false, # ditto; all detonations go to assets to deal with
		#	"make_twin_visible": false, # only true for TELEPORT_OBJECT_IN; get rid of it here
		#	"media_effect": false, # TO DO: true for liquid splash effects only; delete here
		#},
		
		# TO DO: we could include scene [sub]path/name here, or we can add `@export detonation_type: DetonationType.GRENADE_EXPLOSION` to the detonation scene's base script and set the mapping there (requires attaching to a scene); probably best to use scene name, minus ".tscn" here and construct the full path to the scene when loading it (once we convert)
		
		"area_of_effect": 0.75, # moved from Projectiles
		"damage_type": Enums.DamageType.EXPLOSION,
		#"alien_damage": false, # TO DO: shouldn't need this
		"base": 80,
		"random": 20,
		"scale": 0.0,
		#"delay": 0, # 0.5sec for TELEPORT_OBJECT_IN; null or 0 otherwise
		#"delay_sound": null, # M3 Physics exporter has buggy field (uses wrong string collection); however, looks like only LARGE_WATER_SPLASH, LARGE_WATER_EMERGENCE, TELEPORT_OBJECT_IN have non-null values so let's punt to
	},
]

