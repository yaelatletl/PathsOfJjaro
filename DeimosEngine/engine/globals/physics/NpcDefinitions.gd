extends Node



const NPC_DEFINITIONS := [
		{
			"type": Enums.SpeciesType.FIGHTER,
			"subtype": "Projectile",
			"skill_level": "Major",
			
			"name": "Fighter Major Projectile",
			
			
			"health": 80, # was "vitality"
			"impact_modifiers": {}, # replace immunities and weaknesses with dict of zero or more floats, typically: weakness=2.0, normal=1.0 (default; can be omitted), resistant=0.5, immune=0.0
			
			"brain": {
				"intelligence": 8,
				"speed": 0.041015625,
				"visual_range": 30.0,
				"dark_visual_range": 5.0,
				"half_visual_arc": 90.0,
				"half_vertical_visual_arc": 29.53125,
				"door_retry_mask": 31,
				"attack_frequency": 90,
			},
			
			"attacks": {
				"melee": {
					"projectile_type": Enums.ProjectileType.FIGHTER_MELEE,
					"repetitions": 1,
					"error": 0.0,
					"range": 1.0,
					"projectile_origin": [0.0625, 0.0, 0.25], # TO DO: position relative to NPC's center
				},
				"ranged": {
					"projectile_type": Enums.ProjectileType.FIGHTER_BOLT,
					"repetitions": 1,
					"error": 2.109375,
					"range": 12.0,
					"projectile_origin": [0.0625, 0.0, 0.25], # TO DO: ditto
				},
			},
			# separate attack, defense, run_away so we can indicate preferred behaviors?
			
			# TO DO: we could implement run-away/bezerker as a "promotion", with fixed/adjustable health threshold at which its behavior flips; the behavior itself might be defined as a dictionary of one or more fields which overrides the original dictionary field[s] used to initialize the NPCClass from which all NPCs of a specific Family+Species derive, and which have individual properties overridden for different SkillLevel; in effect, one definition can extend another and an NPC instance's npc_class property can have a different NPCClass assigned at any time to modify its behavior (e.g. from normal to bezerker)
			
			
			"flags": {
				"omniscient": false,
				"flies": false,
				"is_alien": true,
				"major": true,
				"minor": false,
				"cannot_skip": false,
				"floats": false,
				"cannot_attack": false,
				"uses_sniper_ledges": true,
				"is_invisible": false,
				"is_subtly_invisible": false,
				"kamikaze": false,
				"berserker": true,
				"enlarged": false,
				"delayed_hard_death": false,
				"fires_symmetrically": false,
				"nuclear_hard_death": false,
				"cannot_fire_backwards": false,
				"can_die_in_flames": true,
				"waits_with_clear_shot": false,
				"tiny": false,
				"attacks_immediately": false,
				"not_afraid_of_water": false,
				"not_afraid_of_sewage": false,
				"not_afraid_of_lava": false,
				"not_afraid_of_goo": false,
				"can_teleport_under_media": false,
				"chooses_weapons_randomly": false
			},
			
			# TO DO: see how many different IFF records there are; if there’s lots of commonality, move them into their own FRIEND_OR_FOE table and use the record's ID here
			"friend_or_foe": {
				Enums.SpeciesType.FIGHTER: Enums.FriendOrFoe.FRIEND,
				Enums.SpeciesType.SECURITY_OFFICER: Enums.FriendOrFoe.FOE,
				# etc.
			},
			
			"class": 32,
			"friends": [
				"Fighter",
				"Trooper",
				"Hunter",
				"Enforcer",
				"Juggernaut"
			],
			"enemies": [
				"Player",
				"Bob",
				"MADD",
				"Possessed Hummer",
				"Defender",
				"Tick",
				"Yeti"
			],
			
			# these move to NPC scene assets
			"sound_pitch": 1.125,
			"activation_sound": "fighter activate",
			"friendly_activation_sound": null,
			"clear_sound": null,
			"kill_sound": null,
			"apology_sound": null,
			"friendly_fire_sound": null,
			"flaming_sound": "fighter wail",
			"random_sound": "fighter chatter",
			"random_sound_mask": 15,
			
			
			"carrying_pickable": null,
			
			"radius": 0.19921875,
			"height": 0.7998047,
			
			
			"preferred_hover_height": 0.0,
			
			"minimum_ledge_delta": -4.0,
			"maximum_ledge_delta": 0.3330078,
			
			"external_velocity_scale": 0.75,
			
			
			"impact_effect": "fighter blood splash",
			"melee_impact_effect": null,
			"contrail_effect": null,
			
			
			
			"gravity": 0.0078125,
			"terminal_velocity": 0.07128906,
			"shrapnel_radius": null,
			
			
			# this is optional DetonationType
			"shrapnel_damage": {
				"damage_type": null,
				"flags": {
					"alien_damage": false
				},
				"base": 0,
				"random": 0,
				"scale": 0.0
			},
			
			
		#	"hit_sequence": 4,
		#	"hard_dying_sequence": 1,
		#	"soft_dying_sequence": 3,
		#	"hard_dead_sequence": 6,
		#	"soft_dead_sequence": 5,
		#	"stationary_sequence": 7,
		#	"moving_sequence": 0,
		#	"teleport_in_sequence": 12,
		#	"teleport_out_sequence": 12,
			
		},
	
]







const __DEFINITIONS := [ # dummy; this is just to list types and names here for reference; full definitions go in NPC_DEFINITIONS
		{
			"type": Enums.SpeciesType.SECURITY_OFFICER, # only relevant in glass/mirror reflections/multiplayer/bots
			"name": "SecurityOfficer",
		},
		
		{
			"type": Enums.SpeciesType.HUMAN_CIVILIAN, # Crew/Science/Security/Assimilated
			"name": "HumanCivilian",
		},

		{
			"type": Enums.SpeciesType.HUMAN_PISTOL, # Crew/Science/Security/Assimilated
			"name": "HumanPistol",
		},

		{
			"type": Enums.SpeciesType.HUMAN_FUSION, # Crew/Science/Security/Assimilated
			"name": "HumanFusion",
		},
		

		{
			"type": Enums.SpeciesType.HUMAN_DRONE, # Minor/Possessed
			"name": "MADD",
		},
			
		{
			"type": Enums.SpeciesType.FIGHTER, # Minor/Major; melee-only/melee+range (Projectile)
			"name": "Fighter",
		},
			
		{
			"type": Enums.SpeciesType.TROOPER, # Minor/Major
			"name": "Trooper",
		},

		{
			"type": Enums.SpeciesType.HUNTER, # Minor/Major/Super (mother of all hunters)
			"name": "Hunter",
		},
		
		{
			"type": Enums.SpeciesType.ENFORCER,
			"name": "Enforcer",
		},
		
		{
			"type": Enums.SpeciesType.SPHT_CONTROLLER,
			"name": "SphtController",
		},

		{
			"type": Enums.SpeciesType.JUGGERNAUT, # Minor/Major
			"name": "Juggernaut",
		},

		{
			"type": Enums.SpeciesType.PFHOR_DRONE, # Minor/Major
			"name": "Defender",
		},
		
		{
			"type": Enums.SpeciesType.SPHT, # Minor/Major/MinorInvisible/MajorInvisible
			"name": "Spht",
		},
			
		{
			"type": Enums.SpeciesType.SPHT_KR, # Minor/Major/MinorInvisible/MajorInvisible
			"name": "SphtKr",
		},
		
		{
			"type": Enums.SpeciesType.PFHOR_CYBORG, # Minor/Major/FlameMinor/FlameMajor/Super
			"name": "Cyborg",
		},
		
		{
			"type": Enums.SpeciesType.HULK, # Minor/Major
			"name": "Hulk",
		},
		
		{
			"type": Enums.SpeciesType.HOUND,
			"name": "Hound",
		},
		
		{
			"type": Enums.SpeciesType.LOOKER, # think there is minor and invisible; check this
			"name": "Looker",
		},

		{
			"type": Enums.SpeciesType.WASP, # Minor/Major
			"name": "Wasp",
		},


		{
			"type": Enums.SpeciesType.YETI, # Water/Sewage/Lava
			"name": "Yeti",
		},

		{
			"type": Enums.SpeciesType.HUMMER, # Minor/Major/BigMinor/BigMajor/Possessed
			"name": "Hummer",
		},
		
		{
			"type": Enums.SpeciesType.TICK, # Oxygen/Energy/Kamikaze
			"name": "Tick",
		},



]

