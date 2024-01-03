extends Node



# TO DO: include "plural_name" field (pluralized long_name, e.g. Magnum Pistols) for use in HUD's inventory overlay

const INVENTORY_DEFINITIONS := [ # for now, this array is ordered same as PickableType enum and M2 map data, so we can convert map JSONs to PickableItems
	# TO DO: fix/finish max_counts, counts, short_name, plural_[long_]name
	# caution: pickable_type's int value must be same as array index
	{"pickable_type": Enums.PickableType.FIST,                  "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "Fist",                  "short_name": "FIST", "max_count":  1, "count":  1},
	{"pickable_type": Enums.PickableType.MAGNUM_PISTOL,         "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": ".44 Magnum Pistol",     "short_name": "MA44", "max_count":  2, "count":  1},
	{"pickable_type": Enums.PickableType.MAGNUM_MAGAZINE,       "pickable_family": Enums.PickableFamily.AMMO,     "long_name": ".44 Magnum Magazine",   "short_name": "MG44", "max_count": 50, "count":  1},
	{"pickable_type": Enums.PickableType.PLASMA_PISTOL,         "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "Plasma Pistol",         "short_name": "ZEUS", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.PLASMA_ENERGY_CELL,    "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "Plasma Energy Cell",    "short_name": "CELL", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.ASSAULT_RIFLE,         "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "MA75C Assault Rifle",   "short_name": "MA75", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.AR_MAGAZINE,           "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "AR Magazine",           "short_name": "MA75", "max_count": 15, "count":  0},
	{"pickable_type": Enums.PickableType.AR_GRENADE_MAGAZINE,   "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "AR Grenade Magazine",   "short_name": "GREN", "max_count":  8, "count":  0},
	{"pickable_type": Enums.PickableType.MISSILE_LAUNCHER,      "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "Missile Launcher",      "short_name": "SPNK", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.MISSILE_2_PACK,        "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "Missile 2-Pack",        "short_name": "SSM2", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.INVISIBILITY_POWERUP,  "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Invisibility Powerup",  "short_name": "",     "max_count":  2, "count":  0},
	{"pickable_type": Enums.PickableType.INVINCIBILITY_POWERUP, "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Invincibility Powerup", "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.INFRAVISION_POWERUP,   "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Infravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.ALIEN_WEAPON,          "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "Alien Weapon",          "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.ALIEN_WEAPON_AMMO,     "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "Alien Weapon Ammo",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.FLAMETHROWER,          "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "Flamethrower",          "short_name": "TOZT", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.FLAMETHROWER_CANISTER, "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "Flamethrower Canister", "short_name": "NAPM", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.EXTRAVISION_POWERUP,   "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Extravision Powerup",   "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.OXYGEN_POWERUP,        "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Oxygen Powerup",        "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.ENERGY_POWERUP_X1,     "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Energy Powerup x1",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.ENERGY_POWERUP_X2,     "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Energy Powerup x2",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.ENERGY_POWERUP_X3,     "pickable_family": Enums.PickableFamily.POWERUP,  "long_name": "Energy Powerup x3",     "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.SHOTGUN,               "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "Shotgun",               "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.SHOTGUN_CARTRIDGES,    "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "Shotgun Cartridges",    "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.SPHT_DOOR_KEY,         "pickable_family": Enums.PickableFamily.KEY,      "long_name": "S'pht Door Key",        "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.UPLINK_CHIP,           "pickable_family": Enums.PickableFamily.KEY,      "long_name": "Uplink Chip",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.LIGHT_BLUE_BALL,       "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "Light Blue Ball",       "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.THE_BALL,              "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "The Ball",              "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.VIOLET_BALL,           "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "Violet Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.YELLOW_BALL,           "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "Yellow Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.BROWN_BALL,            "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "Brown Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.ORANGE_BALL,           "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "Orange Ball",           "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.BLUE_BALL,             "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "Blue Ball",             "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.GREEN_BALL,            "pickable_family": Enums.PickableFamily.OTHER,    "long_name": "Green Ball",            "short_name": "",     "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.SUBMACHINE_GUN,        "pickable_family": Enums.PickableFamily.WEAPON,   "long_name": "Submachine Gun",        "short_name": "FSSM", "max_count":  1, "count":  0},
	{"pickable_type": Enums.PickableType.SUBMACHINE_GUN_CLIP,   "pickable_family": Enums.PickableFamily.AMMO,     "long_name": "Submachine Gun Clip",   "short_name": "MGFS", "max_count":  1, "count":  0},
	# TO DO: add M1/MCR item types (e.g. PASS_KEY, SECURITY_REPAIR_CHIP)
]

