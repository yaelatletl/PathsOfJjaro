extends Node


# TO DO: what about body-media transitions? e.g. Player runs through cryo gas, Fighter falls into laval, stool falls into water; this is a much smaller subset of transitions so may be best in its own table, or we can generalize PROJECTILE_TRANSITIONS to PHYSICS_BODY_TRANSITIONS; Q. what about a stationary body in decompression (environment transitions from air to vacuum? worry about that if/when needed - the initial Pfhor-in-airlock scene is a scripted event so doesn't need it)


# liquid stops most projectiles; fusion instantly detonates on liquid impact, dealing player damage (minor: 30±10, major: 80±20; I suspect both triggers may do shrapnel damage underwater but would need to test) - how does fusion know to do instant damage - is it hardcoded? (there is no obvious flag for this)



const PROJECTILE_TRANSITION_DEFINITIONS := [ # many-to-many relationship between ProjectileType and Level/NPC/Scenery/Prop/Liquid/etc BodyType, describing what happens when a projectile transitions from current medium to something else (Q. how to do splash effects? these probably only need to know mass and velocity to scale the splash effect to any size and direction)
	
	# callback: projectile_transitioned(from_species,from_body,to_species,to_body,projectile,body)
	
	{
		"projectile": Enums.ProjectileType.PISTOL_BULLET,
		"transitions": [
			{
				"from": [Enums.FamilyType.MEDIUM, Enums.BodyType.ANY], # any medium
				"into": [Enums.FamilyType.PFHOR, Enums.BodyType.FLESH],
				"animation": Enums.AnimationType.FIGHTER_BLOOD_SPLASH,
				"detonation": Enums.DetonationType.PISTOL_BULLET_DETONATION, # TO DO: differentiate detonation from visual effect; detonations are categorized by DamageType - there may be several STAFF_BOLT
			}
		],
	},
	
	{
		"projectile": Enums.ProjectileType.FIGHTER_BOLT,
		"from": [Enums.FamilyType.MEDIUM, Enums.BodyType.AIR],
		"into": [Enums.FamilyType.HUMAN, Enums.BodyType.FLESH],
		"animation": Enums.AnimationType.FIGHTER_PROJECTILE_DETONATION,
		"detonation": Enums.DetonationType.FIGHTER_PROJECTILE_DETONATION,
	},
	
	
]




const NPC_TRANSITION_DEFINITIONS := [ # many-to-many relationship between SpeciesType and Level/NPC/Scenery/Prop/Liquid/etc BodyType
	
	]
