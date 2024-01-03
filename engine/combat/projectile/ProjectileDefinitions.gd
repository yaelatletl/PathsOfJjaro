extends Node


# TO DO: fill in these


const PROJECTILE_DEFINITIONS := [
	
	{
		"projectile_type": Enums.ProjectileType.MINOR_FIST,
		"radius": 0.0,
	},
	
	{
		"projectile_type": Enums.ProjectileType.MAJOR_FIST,
		"radius": 0.0,
	},
	
	{
		"projectile_type": Enums.ProjectileType.PISTOL_BULLET,
		"radius": 0.0,
	},
	
	{
		"projectile_type": Enums.ProjectileType.GRENADE,
		"radius": 0.0,
	},
	
	{
		"projectile_type": Enums.ProjectileType.FIGHTER_MELEE,
		"radius": 0.0,
	},
	
	{
		"projectile_type": Enums.ProjectileType.FIGHTER_BOLT,
		"radius": 0.0,
	},
	
	{
		"projectile_type": Enums.ProjectileType.COMPILER_BOLT_MINOR,
		"radius": 0.0,
	},
	
	
	{
		"projectile_type": Enums.ProjectileType.COMPILER_BOLT_MAJOR,
		"radius": 0.0,
	},
	
	{
		# the theoretical advantage of splitting a projectile's type into a hierarchy is debatable, e.g. we can define a wildcard "ANY|RIFLE_BULLET" transition that works for any kind of "bullet", human or alien, with the option of overriding parts of it where we want to customize - e.g. if Pfhor bullets have a different blood-splash size to Human bullets, or if Pfhor grenades have a different shape and contrail color to Human grenades but otherwise deal the same damage; for sake of getting something working, let's ignore this for now and use a single "projectile_type" which matches a trigger's "projectile_type" in WeaponDefinitions
		#
		# note: if we do use a hierarchy, it might be better to use strings of form e.g. "type.subtype.strength", rather than multiple enums: while strings will need parsing, they will be easier to read once definition dictionaries are moved to external JSON files; plus our WAD build tools can replace the string with a uniquely generated int
		#
		#"family": Enums.FamilyType.HUMAN,
		#"name": Enums.ProjectileType.RIFLE_BULLET,
		#
		"projectile_type": Enums.ProjectileType.RIFLE_BULLET,
		
		# we may use relational tables for joining contrail, boundary transition, detonation, visual effect; Q. visual effect may represent both visible projectiles in flight (any contrail would be part of that), with state machine transitions indicating looped or one-time animation; the states are defined in tables, not code
		
		
		# boundary transitions; TO DO: see also boundary transition flags - all of these go away and are replaced by many-to-many relationship which can be represented as 2D lookup table; we might use a dictionary of dictionaries for this as it may be quite sparse, with a default fallback value for undefined keys; alternatively, we might use several attributes to determine the behavior type, e.g. all projectiles produce a blood splash, but the exact splash type is determined by a species type: human, simulacrum, Pfhor, Drinnol, Wasp, etc. This'd allow definitions to express *what* something means, with lookup tables determining exactly *how* to behave when encountered - replacing a single effect_type property with a huge number of enums to choose correctly from with 3 or 4 properties (substance, species, special, etc) with a handful of enums each
		#"detonation_effect": DetonationType.BULLET_RICOCHET,
		#"media_detonation_effect": DetonationType.ROCKET_EXPLOSION,
		
		# projectile contrail; this becomes the view scene's responsibility
		#"contrail_effect": null,
		#"ticks_between_contrails": DetonationType.ROCKET_EXPLOSION, # TO DO: exporter bug; should be int
		#"maximum_contrails": DetonationType.ROCKET_EXPLOSION, # TO DO: ditto
		
		
		"media_projectile_promotion": null, # minor/major fusion, rocket; i.e. these penetrate liquids; all others do not # note: minor/major fusion when it hits water promotes to minor/major fusion dispersal which immediately explodes (-ve range, originally possibly -1 or other flag-like int without fixed-point conversion); TO DO: transitions can also handle switch to Detonation/Effect
		
		
		"radius": 0.0, # all projectiles use simple Sphere for collider
		
		# moved to DETONATION_DEFINITIONS
		#"area_of_effect": 0.0,
		#"damage": {
		#	"damage_type": DamageType.PROJECTILE,
		#	"base": 9,
		#	"random": 6,
		#	"scale": 0.0,
		#	"flags": {
		#		"alien_damage": false, # TO DO: get rid of this; if we need an alien_damage flag at all it should go on Detonation or Damage; however, define separate ProjectileType.HUMAN_PROJECTILE and ProjectileType.ALIEN_PROJECTILE first
		#	},
		#},
		"flags": {
			"stop_when_animation_loops": false, # true for flamethrower only (which also has "speed":0.333,"maximum_range":-0.00097,"radius":0.333,"area_of_effect":0.0)
			"persistent": false, # true for flamethrower only
			
			"alien": false, # TO DO: what does this do in Classic?
			
			# pathfinding
			"guided": false,
			
			"affected_by_gravity": false, # TO DO: combine these three into dict where keys are all gravities used in game and values are gravity to apply to projectile (0.0 = none, 1.0 = 1G)
			"affected_by_half_gravity": false,
			"doubly_affected_by_gravity": false,
			
			"no_horizontal_error": false, # these'd be better as floats?
			"no_vertical_error": false,
			"positive_vertical_error": false,
			"horizontal_wander": false,
			"vertical_wander": false,
			
			
			"melee": false, # TO DO: what does this do in Classic? can we get rid of it? need to check AO code
			
			
			# TO DO: these flags are true for ball only; any special cases like this should be defined as Projectile subclasses that implement their own gameplay behavior
			#"persistent_and_virulent": false,
			#"becomes_item_on_detonation": false,
			
			# TO DO: rest of these flags should be replaced with boundary transitions
			"usually_pass_transparent_side": true,
			"sometimes_pass_transparent_side": false,
			"rebounds_from_floor": false,
			"penetrates_media": false,
			"penetrates_media_boundary": false,
			"passes_through_objects": false,
			"can_toggle_control_panels": false,
			"bleeding_projectile": true, # all bullets
			
		},
		"speed": 1.0,
		"maximum_range": -0.0009765625,
		"sound_pitch": 1.0,
		"flyby_sound": null,
		"rebound_sound": null,
	},
]

