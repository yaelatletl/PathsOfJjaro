extends Node



# TO DO: use count=-1 to indicate existing InventoryItems' count is not changed; this lets us put item definitions into per-level wad, along with the map and physics

# TO DO: add plural_name (pluralized long_name, e.g. Magnum Pistols)
const PICKABLE_DEFINITIONS := [ # for now, this array is ordered same as PickableType enum and M2 map data, so we can convert map JSONs to PickableItems
	# TO DO: fix/finish max_counts, counts, short_name, plural_[long_]name
	# note: while keys could be shorter, it's best to keep them same as identifiers used in the code
	{"pickable": Enums.PickableType.FIST,                  "long_name": "Fist",                  "short_name": "FIST", "max_count":  2, "count":  2},
	{"pickable": Enums.PickableType.MAGNUM_PISTOL,         "long_name": ".44 Magnum Pistol",     "short_name": "MA44", "max_count":  2, "count":  2},
	{"pickable": Enums.PickableType.MAGNUM_MAGAZINE,       "long_name": ".44 Magnum Magazine",   "short_name": "MG44", "max_count": 50, "count":  3},
	{"pickable": Enums.PickableType.PLASMA_PISTOL,         "long_name": "Plasma Pistol",         "short_name": "ZEUS", "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.PLASMA_ENERGY_CELL,    "long_name": "Plasma Energy Cell",    "short_name": "CELL", "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.ASSAULT_RIFLE,         "long_name": "MA75C Assault Rifle",   "short_name": "MA75", "max_count":  1, "count":  1},
	{"pickable": Enums.PickableType.AR_MAGAZINE,           "long_name": "AR Magazine",           "short_name": "MA75", "max_count": 15, "count":  4},
	{"pickable": Enums.PickableType.AR_GRENADE_MAGAZINE,   "long_name": "AR Grenade Magazine",   "short_name": "GREN", "max_count":  3, "count":  3},
	{"pickable": Enums.PickableType.MISSILE_LAUNCHER,      "long_name": "Missile Launcher",      "short_name": "SPNK", "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.MISSILE_2_PACK,        "long_name": "Missile 2-Pack",        "short_name": "SSM2", "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.INVISIBILITY_POWERUP,  "long_name": "Invisibility Powerup",  "short_name": "",     "max_count":  2, "count":  0},
	{"pickable": Enums.PickableType.INVINCIBILITY_POWERUP, "long_name": "Invincibility Powerup", "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.INFRAVISION_POWERUP,   "long_name": "Infravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.ALIEN_WEAPON,          "long_name": "Alien Weapon",          "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.ALIEN_WEAPON_AMMO,     "long_name": "Alien Weapon Ammo",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.FLAMETHROWER,          "long_name": "Flamethrower",          "short_name": "TOZT", "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.FLAMETHROWER_CANISTER, "long_name": "Flamethrower Canister", "short_name": "NAPM", "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.EXTRAVISION_POWERUP,   "long_name": "Extravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.OXYGEN_POWERUP,        "long_name": "Oxygen Powerup",        "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.ENERGY_POWERUP_X1,     "long_name": "Energy Powerup x1",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.ENERGY_POWERUP_X2,     "long_name": "Energy Powerup x2",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.ENERGY_POWERUP_X3,     "long_name": "Energy Powerup x3",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.SHOTGUN,               "long_name": "Shotgun",               "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.SHOTGUN_CARTRIDGES,    "long_name": "Shotgun Cartridges",    "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.SPHT_DOOR_KEY,         "long_name": "S'pht Door Key",        "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.UPLINK_CHIP,           "long_name": "Uplink Chip",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.LIGHT_BLUE_BALL,       "long_name": "Light Blue Ball",       "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.THE_BALL,              "long_name": "The Ball",              "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.VIOLET_BALL,           "long_name": "Violet Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.YELLOW_BALL,           "long_name": "Yellow Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.BROWN_BALL,            "long_name": "Brown Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.ORANGE_BALL,           "long_name": "Orange Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.BLUE_BALL,             "long_name": "Blue Ball",             "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.GREEN_BALL,            "long_name": "Green Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.SUBMACHINE_GUN,        "long_name": "Submachine Gun",        "short_name": "FSSM", "max_count":  1, "count":  0},
	{"pickable": Enums.PickableType.SUBMACHINE_GUN_CLIP,   "long_name": "Submachine Gun Clip",   "short_name": "MGFS", "max_count":  1, "count":  0},
	# TO DO: add M1/MCR item types (e.g. PASS_KEY, SECURITY_REPAIR_CHIP)
]

