extends Node


# engine/globals/Enums.gd


# note: these use M3 Physics values (adapting properties as needed); M1-only definitions can be added once the data structures are finalized; any discrepancies between M1 and M2, use the M2 definitions


# note: use enums for MRC development (with same names and int values as Classic M2 files, caveat M1-only objects which should be added to enums after the M2 names) as that gives us typechecking
#
# if/when we add 3rd-party modding support, these enums can be changed to ints (TypeIDs), trading GDScript safety for extensibility; similarly, the definition tables can be recreated as external JSONs; the JSONs can also contain dictionaries containing the int-string mappings; a high-level WAD editor can perform consistency checks to ensure JSONs are correctly formed and don't contain any invalid type IDs (but until we develop those authoring tools, GDScript's static typechecker is the most robust option we have, though it's weak on arrays and can't validate dictionary structures)


func make_asset_id(asset_type: AssetType, asset_subtype: int) -> int:
	return asset_type << 24 | asset_subtype
	



enum AssetType {
	WEAPON_IN_HAND = 1,
	PROJECTILE,
	ANIMATION, # 3D and/or 2D?
	PICKABLE,
	
}



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
	CIVILIAN_CREW, # TODO: rename these PISTOL_CREW, etc as they are M2's armed Bobs, and use CIVILIAN_CREW for M1's unarmed crew members
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
	# TODO: M1-only types (Hulk, Wasp, Looker, MADD, and Deimos's unarmed crew; we may also add Pfhor crew on Boomer maps, which will be unarmed, unarmored, unmasked Pfhor which normally run away from SO and only use weak teeth and claws for defense when cornered; conversely we can add a few [fairly ineffectual] pistol Bobs to Deimos's Ch2 levels, with some extra Pfhor and scripted scenes so they don't affect the gameplay balance)
}

enum PickableFamily {
	WEAPON,
	AMMO,
	KEY,
	POWERUP,
	OTHER,
}

enum PickableType { # TODO: can GDScript coerce enums to and from ints?
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
	# TODO: M1/MCR items (e.g. DEFENSE_REPAIR_CHIP, ENGINEERING_PASS_KEY)
	NONE,
}


enum WeaponType {
	FIST             = PickableType.FIST,
	MAGNUM_PISTOL    = PickableType.MAGNUM_PISTOL,
	PLASMA_PISTOL    = PickableType.PLASMA_PISTOL,
	ASSAULT_RIFLE    = PickableType.ASSAULT_RIFLE,
	MISSILE_LAUNCHER = PickableType.MISSILE_LAUNCHER,
	ALIEN_WEAPON     = PickableType.ALIEN_WEAPON,
	FLAMETHROWER     = PickableType.FLAMETHROWER,
	SHOTGUN          = PickableType.SHOTGUN,
	SUBMACHINE_GUN   = PickableType.SUBMACHINE_GUN,
}


enum ProjectileType {
	MINOR_FIST,
	MAJOR_FIST,
	
	ROCKET, # TODO: is this index 0 or 1? also, what are M1-only types (wasp spit, hulk slap, looker instaboom, any others)? we should append M1-only enums and remap the M1 physics definitions to those new values, which allows us to have a single bestiary for all 3 scenarios
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
	# TODO: add M1-only hulk slap, wasp spit, looker instaboom, simulacrum instaboom projectile types after the M2 types
}



# note: projectile impacts are described by 2 enums: AnimationType, which provides audiovisual effect, and DetonationType


enum AnimationType { # these are visual animations, both in-flight and on-impact; corresponds to Classic's EffectType
	
	MINOR_FIST_DETONATION,
	MAJOR_FIST_DETONATION,
	
	HUMAN_BULLET_RICOCHET, # TODO: separate Species?
	
	MINOR_FUSION_DETONATION,
	MAJOR_FUSION_DETONATION,
	MAJOR_FUSION_CONTRAIL,
	ROCKET_EXPLOSION,
	ROCKET_CONTRAIL, # TODO: use M2 int values
	GRENADE_EXPLOSION,
	GRENADE_CONTRAIL, # TODO: use M2 int values
	ALIEN_WEAPON_RICOCHET,
	FLAMETHROWER_BURST, # fiery plume
	FLAMETHROWER_IMPACT, # fiery plume hit something
	
	MINOR_FUSION_DISPERSAL, # alternate Explosion that does 0 damage when a projectile reaches the end of its lifetime without hitting anything
	MAJOR_FUSION_DISPERSAL, # ditto
	OVERLOADED_FUSION_DISPERSAL, # ditto
	
	
	HUMAN_BLOOD_SPLASH, # player, civilian Bob, pistol Bob
	HUMAN_ARMOR_SPARK, # fusion Bob, MADD
	
	SIMULACRUM_BLOOD_SPLASH, # civilian, pistol assimilated; for fusion assimilated, use PFHOR_ARMOR_SPARK
	
	PFHOR_BLOOD_SPLASH, # yellow blood splash
	PFHOR_ARMOR_SPARK, # this should be visibly different to HUMAN_ARMOR_SPARK so shooting assimilated vacbob is distinguishable from human vacbob
	
	FIGHTER_MELEE_DETONATION,
	FIGHTER_BOLT_DETONATION,
	
	TROOPER_BULLET_RICOCHET, # use similar effect to M1's alien weapon to distinguish it from human bullets
	HUNTER_PROJECTILE_DETONATION,
	
	COMPILER_BOLT_MINOR_DETONATION,
	COMPILER_BOLT_MAJOR_DETONATION,
	COMPILER_BOLT_MAJOR_CONTRAIL,
	
	MINOR_PFHOR_DRONE_DETONATION, # TODO: is this exploding Pfhor drone? Q. what does Pfhor drone fire again (some sort of energy bolt)? can we make it fire same/similar projectile to Trooper bullet without affecting gameplay? it'd be nice to create some consistency in Pfhor munitions
	MAJOR_PFHOR_DRONE_DETONATION,
	
	# TODO: change these names for clarity
	MINOR_HUMMER_PROJECTILE_DETONATION, 
	MAJOR_HUMMER_PROJECTILE_DETONATION,
	DURANDAL_HUMMER_PROJECTILE_DETONATION, # ?
	HUMMER_SPARK,
	
	CYBORG_PROJECTILE_DETONATION, # might rename PFHOR_CYBORG or PFHOR_TANK as there's several types of cyborg in Marathon 1-3! (we'll assume the Pfhor cyborg is an armored shell around the mangled remainder of Pfhor that survived previous combat; we may jig its visual design to make this clearer, e.g. three red eyes on its "head")
	CYBORG_BLOOD_SPLASH,
	
	WATER_YETI_BLOOD_SPLASH,
	SEWAGE_YETI_BLOOD_SPLASH,
	LAVA_YETI_BLOOD_SPLASH,
	YETI_MELEE_DETONATION,
	SEWAGE_YETI_PROJECTILE_DETONATION,
	LAVA_YETI_PROJECTILE_DETONATION,
	
	
	JUGGERNAUT_SPARK, # since juggernaut is further away, it'll need an enlarged spark animation to be seen
	JUGGERNAUT_MISSILE_CONTRAIL,
	LARGE_JJARO_EMERGENCE,
	
	
	# WATER_LAMP_BREAKING, # TODO: should this effect be incorporated into breakable scenery's animation? or do we define general animations here, e.g. GLASS_BREAKING, bearing in mind these animations are played on top of whatever hit animation the body itself plays; we can decide once some smashable props are prototypes for in-world testing
	# LAVA_LAMP_BREAKING,
	# SEWAGE_LAMP_BREAKING,
	# ALIEN_LAMP_BREAKING,
	
	# TODO: what about breakable/unbreakable glass/props? if we can keep breakables simple - e.g. small glass prop, large glass prop, glass window - we might get away with a few generic breaking-glass animations; it depends on the complexity of the asset, and whether it's a full scene with standard API and custom implementation, or if we can have a single general-purpose scene [for each Family] with standard implementation and only Species/Object-specific animations are different? table-driven is preferred as it reduces code and facilitates high-level modding tools (including GUI table editor and table validator - it is easy to check for missing relationships, provide defaults)
	
	METAL_RICOCHET, # general richochet effect; TODO: should all impacts have a default fallback, e.g. if a bullet travelling in air hits something metallic which doesn't define a specific bullet-from-air-into-metal, play a generic METAL_RICHOCHET visual? 
	#
	# also, can we simplify the transition tables so they only need to declare general transitions from media to flesh/armor/glass/etc, with the exact visual effect determined by crossreferencing the impactees's Species (or Family), e.g. bullet + HUMAN + flesh = red, bullet + PFHOR + flesh = yellow; bullet + HUMAN + armor = bright sharp metal-on-metal spark; bullet + PFHOR + armor = dull splattery metal-on-ceramic spark; this would work more like CSS, with a basic "one-size-fits-all" definition which can be inherited and some properties overridden
	#
	# note: However we structure the final static definition tables, our runtime object graph will contain a complete, ready-to-use BodyDefinition instance for every kind of body that exists in the game world. i.e. We only use table lookups when loading the scenario; we don't want expensive dictionary lookups constantly performed throughout gameplay. So we only need to get the DEFINITION structures' design "good enough" that they can be used to instantiate all the Definition objects we need for Arrival's actors. By the time we've built that, we'll have a better idea how to structure the final DEFINITION tables so adding new definitions is logical and [reasonably] easy.
	
	
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
	SMALL_GOO_SPLASH, # M2's Pfhor ship used purple liquids, not green radioactive polys as in M1; we may end up standardizing on one, the other, or both, but we should try to make it consistent across M1, M2, and M3 (which one is used does change the gameplay mechanic, so I'd be inclined to allow both and standardize on a single color, flourescent green OR flourescent purple, for both)
	MEDIUM_GOO_SPLASH,
	LARGE_GOO_SPLASH,
	LARGE_GOO_EMERGENCE,
	SMALL_JJARO_SPLASH,
	MEDIUM_JJARO_SPLASH,
	LARGE_JJARO_SPLASH,
	
	
	
}


enum DamageType { # this determines immunity/weakness flags for each SpeciesType and the HUD effect when the detonation hits player
	
	FIST,
	
	EXPLOSION,
	FIGHTER_MELEE,
	FIGHTER_BOLT,
	PROJECTILE, # TODO: split this into BULLET vs SHELL for non-explosive vs explosive?
	SHOTGUN_PROJECTILE, # need to check M3 physics to see what uses this differently to PROJECTILE
	ABSORBED, # I think this is invincibility impacts
	FLAME,
	ALIEN_WEAPON, # we'll use M2 Enforcer guns, so this is arguably FLAME as well
	COMPILER_BOLT,
	FUSION, # minor, major fusion bolt
	HUNTER_BOLT,
	TELEPORTER, # fairly sure this is only used for screen effect
	PFHOR_DRONE, # can we use same projectile type as Trooper?
	YETI_CLAWS, # TODO: a single CLAWS type should be sufficient
	YETI_PROJECTILE,
	CRUSHING,
	LAVA, # M2 lava (planetary, volcanic magma); this may be different to M1 lava (liquid rock used as reactor coolant)
	SUFFOCATION,
	GOO,
	ENERGY_DRAIN,
	OXYGEN_DRAIN,
	HUMMER_BOLT,
	# TODO: M1-only damage types
	
	HULK_SLAP,
	HOUND_CLAWS,
	CRYO, # we'll use a cryo leak as alternative to Classic's "pillar puzzle" on Arrival; i.e. the user can choose to solve it (backtrack and shut down the cryo leak at the control panel) or run past it (which will deal survivable damage as long as player hasn't already lost too much health; the player's ability to survive G8 without frozen damage will be overlooked)
	
	NONE, # satisfies type checker (we could use `null` = 'no damage' but GDScript lacks an optional type so NONE is the lesser evil; we can reorder DamageType enum later to make its int value `0`); see overload_damage_type
}


enum DetonationType { # determines damage type, health delta, shrapnel radius
	
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
	FIGHTER_BOLT_DETONATION,
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
	
	# let's add damage types for media and use the same mechanism for both projectile- and media-inflicted health loss
	LAVA_DAMAGE,
	#HUMAN_RADIATION_DAMAGE,
	PFHOR_RADIATION_DAMAGE,
	CRUSH_DAMAGE,
	# TODO: do we need CRUSH_DEATH and SUFFOCATION_DEATH? i.e. is there any case where these fatalities would do shrapnel damage? (e.g. does Hunter explode into shrapnel when crushed? probably redundant, TBH)
	# note: oxygen depletion and suffocation death are orthogonal to health damage (e.g. a player fully under lava depletes both health and oxygen), so let's hardcode oxygen depletion separately 
	
	# TODO: M1 detonations
	HULK_MELEE_DETONATION,
	WASP_PROJECTILE_DETONATION,
	LOOKER_DETONATION,
	SPHT_CONTROLLER_DETONATION, # let's make this moment a bit more dramatic when we get to it!
}



# TODO: when a projectile hits something, look up its action (detonation/effect/promotion) here:


enum FamilyType {
	HUMAN,
	PFHOR,
	SPHT,
	ALIEN,
	LEVEL, # TODO: rename "Level" layer to "Architecture" and rename this ARCHITECTURE? (the word "Level" is ambiguous as it may refer to everything in a map or just its walls+ceilings+floors)
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
	GLASS, # wall, scenery, prop; TODO: need `"destructible":bool`
	AIR,
	CRYO,
	FLAME,
	WATER,
	SEWAGE,
	LAVA,
	#PLASMA, # undecided on this; leave it for now, in case we decide to change up gameplay in ENG to use plasma as well as/instead of some lava traps
	#FORCEFIELD,
	
	#CURRENT, # the projectile's current medium, usually air, which it detects itself and passes on as arg to the impact handler: projectile_impacted(from_spe,to_species)
	# TODO: what else?
}


enum ZoneType { # unlike above body types, these are non-solid so must compose with them
	NONE,
	#HUMAN_RADIATION,
	PFHOR_RADIATION, # Boomer's major damage polys (Area) # TODO: Area-inflicted damage is orthogonal to the poly's content so can't be defined here, e.g. a Boomer radiation area may be in air or vacuum (Pfhor lava is presumably a separate case); it might be moved
}

enum FriendOrFoe {
	NEUTRAL,
	FRIEND,
	FOE,
}

