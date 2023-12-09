extends Node


# TO DO: what about body-media transitions? e.g. Player runs through cryo gas, Fighter falls into laval, stool falls into water; this is a much smaller subset of transitions so may be best in its own table, or we can generalize PROJECTILE_TRANSITIONS to PHYSICS_BODY_TRANSITIONS; Q. what about a stationary body in decompression (environment transitions from air to vacuum? worry about that if/when needed - the initial Pfhor-in-airlock scene is a scripted event so doesn't need it)


# liquid stops most projectiles; fusion instantly detonates on liquid impact, dealing player damage (minor: 30±10, major: 80±20; I suspect both triggers may do shrapnel damage underwater but would need to test) - how does fusion know to do instant damage - is it hardcoded? (there is no obvious flag for this)


const PROJECTILE_TRANSITION_DEFINITIONS := [ # many-to-many relationship between ProjectileType and Level/NPC/Scenery/Prop/Liquid/etc BodyType, describing what happens when a projectile transitions from current medium to something else (Q. how to do splash effects? these probably only need to know mass and velocity to scale the splash effect to any size and direction)
	

	
	
	# TO DO: there are a couple ways we could structure this data, either grouping all transitions by projectile type or as flat tables with joins
	{
		"projectile": Enums.ProjectileType.PISTOL_BULLET,
		"from": [
			{
				"family": Enums.FamilyType.MEDIUM,
				"body": Enums.BodyType.ANY, # from any medium (air/liquid/vacuum)...
				"into": [
					{
						"family": Enums.FamilyType.HUMAN, 
						"body": Enums.BodyType.FLESH, # ...into squishy yellow Pfhor meat
						"animation": Enums.AnimationType.HUMAN_BLOOD_SPLASH, # play the yellow red splash
						"detonation": Enums.DetonationType.PISTOL_BULLET_DETONATION, # TO DO: differentiate detonation from visual effect; detonations are categorized by DamageType - there may be several STAFF_BOLT
					},
					{
						"family": Enums.FamilyType.PFHOR, 
						"body": Enums.BodyType.FLESH, # ...into squishy yellow Pfhor meat
						"animation": Enums.AnimationType.PFHOR_BLOOD_SPLASH, # play the yellow blood splash
						"detonation": Enums.DetonationType.PISTOL_BULLET_DETONATION, # TO DO: differentiate detonation from visual effect; detonations are categorized by DamageType - there may be several STAFF_BOLT
					},
				],
			},
		],
	},
	
	{
		"projectile": Enums.ProjectileType.FIGHTER_BOLT,
		"from": [
			{
				"family": Enums.FamilyType.MEDIUM, 
				"body": Enums.BodyType.AIR,
				"into": [
					{
						"family": Enums.FamilyType.HUMAN, 
						"body": Enums.BodyType.FLESH,
						"animation": Enums.AnimationType.FIGHTER_BOLT_DETONATION,
						"detonation": Enums.DetonationType.FIGHTER_BOLT_DETONATION,
					}
				],
			},
		],
	},
	
	
]




const NPC_TRANSITION_DEFINITIONS := [ # many-to-many relationship between SpeciesType and Level/NPC/Scenery/Prop/Liquid/etc BodyType
	
	]
