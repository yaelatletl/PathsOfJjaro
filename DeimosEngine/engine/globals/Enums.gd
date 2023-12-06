extends Node
# global constants and enums


# note: these use M3 Physics values (adapting properties as needed); M1-only definitions can be added once the data structures are finalized; any discrepancies between M1 and M2, use the M2 definitions


# note: use enums for MRC development (with same names and int values as Classic M2 files, caveat M1-only objects which should be added to enums after the M2 names) as that gives us typechecking
#
# if/when we add 3rd-party modding support, these enums can be changed to ints (TypeIDs), trading GDScript safety for extensibility; similarly, the definition tables can be recreated as external JSONs; the JSONs can also contain dictionaries containing the int-string mappings; a high-level WAD editor can perform consistency checks to ensure JSONs are correctly formed and don't contain any invalid type IDs (but until we develop those authoring tools, GDScript's static typechecker is the most robust option we have, though it's weak on arrays and can't validate dictionary structures)



enum __SpeciesType {
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
	PFHOR_DRONE_MINOR,
	PFHOR_DRONE_MAJOR,
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
	FIST = 0,
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
	NONE,
}


enum ProjectileType {
	MINOR_FIST,
	MAJOR_FIST,
	
	ROCKET, # TO DO: is this index 0 or 1? also, what are M1-only types (wasp spit, hulk slap, looker instaboom, any others)? we should append M1-only enums and remap the M1 physics definitions to those new values, which allows us to have a single bestiary for all 3 scenarios
	GRENADE,
	PISTOL_BULLET,
	RIFLE_BULLET,
	SHOTGUN_BULLET,
	
	
	FIGHTER_MELEE,
	FIGHTER_BOLT,
	FLAMETHROWER,
	COMPILER_BOLT_MINOR,
	COMPILER_BOLT_MAJOR,
	ALIEN_WEAPON,
	FUSION_BOLT_MINOR,
	FUSION_BOLT_MAJOR,
	HUNTER,
	ARMAGEDDON_SPHERE,
	ARMAGEDDON_ELECTRICITY,
	JUGGERNAUT_ROCKET,
	TROOPER_BULLET,
	TROOPER_GRENADE,
	MINOR_PFHOR_DRONE,
	MAJOR_PFHOR_DRONE,
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


enum AnimationType { # these are visual animations, both in-flight and on-impact; corresponds to Classic's EffectType
	
	MINOR_FIST_DETONATION,
	MAJOR_FIST_DETONATION,
	
	HUMAN_BULLET_RICOCHET, # TO DO: separate Species?
	
	MINOR_FUSION_DETONATION,
	MAJOR_FUSION_DETONATION,
	MAJOR_FUSION_CONTRAIL,
	ROCKET_EXPLOSION,
	ROCKET_CONTRAIL, # TO DO: use M2 int values
	GRENADE_EXPLOSION,
	GRENADE_CONTRAIL, # TO DO: use M2 int values
	ALIEN_WEAPON_RICOCHET,
	FLAMETHROWER_BURST, # fiery plume
	FLAMETHROWER_IMPACT, # fiery plume hit something
	
	MINOR_FUSION_DISPERSAL, # alternate Explosion that does 0 damage when a projectile reaches the end of its lifetime without hitting anything
	MAJOR_FUSION_DISPERSAL, # ditto
	OVERLOADED_FUSION_DISPERSAL, # ditto
	
	
	
	PLAYER_BLOOD_SPLASH,
	HUMAN_CIVILIAN_BLOOD_SPLASH,
	HUMAN_PISTOL_BLOOD_SPLASH,
	HUMAN_FUSION_BLOOD_SPLASH,
	HUMAN_DRONE_SPARK,
	
	SIMULACRUM_CIVILIAN_BLOOD_SPLASH,
	SIMULACRUM_PISTOL_BLOOD_SPLASH,
	SIMULACRUM_CIVILIAN_FUSION_BLOOD_SPLASH,
	
	FIGHTER_BLOOD_SPLASH,
	TROOPER_BLOOD_SPLASH,
	HUNTER_SPARK,
	ENFORCER_BLOOD_SPLASH,
	PFHOR_DRONE_SPARK,
	
	
	
	FIGHTER_MELEE_DETONATION,
	
	PFHOR_BULLET_RICOCHET,
	HUNTER_PROJECTILE_DETONATION,
	
	COMPILER_BOLT_MINOR_DETONATION,
	COMPILER_BOLT_MAJOR_DETONATION,
	COMPILER_BOLT_MAJOR_CONTRAIL,
	FIGHTER_PROJECTILE_DETONATION,
	
	MINOR_PFHOR_DRONE_DETONATION, # TO DO: is this exploding Pfhor drone? Q. what does Pfhor drone fire again (some sort of energy bolt)? can we make it fire same/similar projectile to Trooper bullet without affecting gameplay? it'd be nice to create some consistency in Pfhor munitions
	MAJOR_PFHOR_DRONE_DETONATION,
	
	
	MINOR_HUMMER_PROJECTILE_DETONATION,
	MAJOR_HUMMER_PROJECTILE_DETONATION,
	DURANDAL_HUMMER_PROJECTILE_DETONATION, # ?
	HUMMER_SPARK,
	
	CYBORG_PROJECTILE_DETONATION,
	CYBORG_BLOOD_SPLASH,
	
	WATER_YETI_BLOOD_SPLASH,
	SEWAGE_YETI_BLOOD_SPLASH,
	LAVA_YETI_BLOOD_SPLASH,
	SEWAGE_YETI_PROJECTILE_DETONATION,
	LAVA_YETI_PROJECTILE_DETONATION,
	
	YETI_MELEE_DETONATION,
	
	JUGGERNAUT_SPARK,
	JUGGERNAUT_MISSILE_CONTRAIL,
	
	SMALL_JJARO_SPLASH,
	MEDIUM_JJARO_SPLASH,
	LARGE_JJARO_SPLASH,
	LARGE_JJARO_EMERGENCE,
	
	
	# WATER_LAMP_BREAKING, # TO DO: should this effect be incorporated into breakable scenery's animation?
	# LAVA_LAMP_BREAKING,
	# SEWAGE_LAMP_BREAKING,
	# ALIEN_LAMP_BREAKING,
	
	# TO DO: what about breakable/unbreakable glass/props? if we can keep breakables simple - e.g. small glass prop, large glass prop, glass window - we might get away with a few generic breaking-glass animations; it depends on the complexity of the asset, and whether it's a full scene with standard API and custom implementation, or if we can have a single general-purpose scene [for each Family] with standard implementation and only Species/Object-specific animations are different? table-driven is preferred as it reduces code and facilitates high-level modding tools (including GUI table editor and table validator - it is easy to check for missing relationships, provide defaults)
	
	METALLIC_CLANG,
	
	# TELEPORT_OBJECT_IN, # how teleport effects are applied to NPCs and PickableItems is TBD (Player will use its own HUD/Viewport animations)
	# TELEPORT_OBJECT_OUT,
	
	# projectiles and NPCs entering/exiting liquids
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
	
	
	
}


enum DetonationType { # determines damage type, health delta, shrapnel radius; it does not determine animation - that is provided separately by AnimationType
	
	# Human
	MINOR_FIST_DETONATION,
	MAJOR_FIST_DETONATION,
	PISTOL_BULLET_DETONATION,
	MINOR_FUSION_DETONATION,
	MAJOR_FUSION_DETONATION,
	OVERLOADED_FUSION_DETONATION,
	RIFLE_BULLET_DETONATION, # AR, MADD
	GRENADE_EXPLOSION, # AR, MADD
	FLAMETHROWER_IMPACT,
	ROCKET_EXPLOSION,
	
	# Pfhor
	FIGHTER_MELEE_DETONATION,
	FIGHTER_PROJECTILE_DETONATION,
	TROOPER_RIFLE_BULLET_DETONATION,
	TROOPER_GRENADE_EXPLOSION,
	HUNTER_PROJECTILE_DETONATION,
	ENFORCER_PROJECTILE_DETONATION, # also used by juggernaut
	
	MINOR_PFHOR_DRONE_DETONATION,
	MAJOR_PFHOR_DRONE_DETONATION,
	CYBORG_FLAMETHROWER_IMPACT,
	CYBORG_PROJECTILE_DETONATION,
	JUGGERNAUT_PROJECTILE_DETONATION,
	
	# Alien
	COMPILER_BOLT_MINOR_DETONATION,
	COMPILER_BOLT_MAJOR_DETONATION,
	
	MINOR_HUMMER_PROJECTILE_DETONATION,
	MAJOR_HUMMER_PROJECTILE_DETONATION,
	DURANDAL_HUMMER_PROJECTILE_DETONATION,
	
	
	YETI_MELEE_DETONATION,
	SEWAGE_YETI_PROJECTILE_DETONATION,
	LAVA_YETI_PROJECTILE_DETONATION,
	
	# TO DO: M1 detonations
}


enum DamageType { # this determines immunity/weakness flags for each SpeciesType and the HUD effect animation to display when a projectile or damaging liquid impacts the player (we've split contrails and any other non-detonation effects into separate EffectsType, although Classic had only a single Effects enum for all of them)
	
	
	EXPLOSION,
	FIGHTER_MELEE,
	FIGHTER_BOLT,
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
	PFHOR_DRONE,
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



# TO DO: when a projectile hits something, look up its action (detonation/effect/promotion) here:


enum FamilyType {
	HUMAN,
	PFHOR,
	SPHT,
	ALIEN,
	LEVEL, # TO DO: rename "Level" layer to "Architecture" and rename this ARCHITECTURE? (the word "Level" is ambiguous as it may refer to everything in a map or just its walls+ceilings+floors)
	SCENERY,
	PROP,
	MEDIUM,
}


enum SpeciesType { # this corresponds to M1-M3 Shapes collections
	ANY,
	SECURITY_OFFICER, # in-game model (for reflections and MP); this is not the model that is rendered for WeaponInHand (although WIH may reuse its arms, possibly from a higher-detail model)
	HUMAN_CIVILIAN,
	HUMAN_PISTOL,
	HUMAN_FUSION,
	HUMAN_DRONE, # MADD
	
	FIGHTER,
	TROOPER,
	HUNTER,
	ENFORCER,
	LOOKER,
	PFHOR_CREW,
	HOUND,
	SPHT_CONTROLLER,
	
	JUGGERNAUT,
	PFHOR_DRONE,
	PFHOR_CYBORG,
	
	SPHT,
	SPHT_KR,
	HULK,
	WASP,
	YETI,
	HUMMER,
	TICK,
	
	GAS,
	VACUUM, # may be NONE or RADIATION
	LIQUID,
	ENERGY_BARRIER,
	
	HARD_WALL,
	SOFT_WALL,
	DOOR,
	CONTROL_PANEL,
}


enum BodyType {
	ANY,
	FLESH, # Bob, player's exposed skin, if any; fighter, trooper (unarmored skin), enforcer, looker, simulacrum; hulk (unarmored skin), wasp; yeti; hummer
	ARMOR, # [ablative/ceramic] player's body armor (same amount of damage, just different visual effect); trooper (armored skin), hunter, drone; hulk (armored skin; same damage, different visual)
	METAL, # MADD; juggernaut; wall, scenery, prop
	METAL_GRATE, # probably destructible SCENERY
	STONE, # wall, scenery
	PLASTIC, # wall, scenery, prop
	GLASS, # wall, scenery, prop; TO DO: need `"destructible":bool`
	AIR,
	CRYO,
	FLAME,
	WATER,
	SEWAGE,
	LAVA,
	PLASMA, # undecided on this; leave it for now, in case we decide to change up gameplay in ENG to use plasma as well as/instead of some lava traps
	FORCE_FIELD,
	
	#CURRENT, # the projectile's current medium, usually air, which it detects itself and passes on as arg to the impact handler: projectile_impacted(from_spe,to_species)
	# TO DO: what else?
}


enum ZoneType { # unlike above body types, these are non-solid so must compose with them
	NONE,
	PFHOR_RADIATION, # Boomer's major damage polys (Area) # TO DO: Area-inflicted damage is orthogonal to the poly's content so can't be defined here, e.g. a Boomer radiation area may be in air or vacuum (Pfhor lava is presumably a separate case); it might be moved
}

enum FriendOrFoe {
	NEUTRAL,
	FRIEND,
	FOE,
}

