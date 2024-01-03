extends Node


# TODO: is this needed? suggest building these animations as .tscn files; chances are everything will be done in those


const ANIMATION_DEFINITONS := [
	{
		"name": Enums.AnimationType.MINOR_FIST_DETONATION, # TODO: rename "animation_type"
		#"collection": "Projectiles",
		#"clut": 0,
		#"sequence": 17,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": false,
			"end_when_transfer_animation_loops": false,
			"sound_only": true,
			"make_twin_visible": false, # only true for TELEPORT_OBJECT_IN; probably don't need it
			"media_effect": false, # TODO: true for liquid splash effects only; get rid of this and use transitions
		},
		"delay": 0,
		"delay_sound": null
	},

	{
		"name": Enums.AnimationType.MAJOR_FIST_DETONATION,
		"collection": "Projectiles",
		"clut": 0,
		"sequence": 17,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": false,
			"end_when_transfer_animation_loops": false,
			"sound_only": true,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": Enums.AnimationType.HUMAN_BULLET_RICOCHET,
		"collection": "Projectiles",
		"clut": 0,
		"sequence": 13,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": Enums.AnimationType.GRENADE_CONTRAIL, # TODO: should contrail be part of the Projectile?
		"collection": "Projectiles",
		"clut": 0,
		"sequence": 4,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	{
		"name": "grenade explosion",
		"collection": "Projectiles",
		"clut": 0,
		"sequence": 9,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": "fighter blood splash",
		"collection": "Pfhor Fighter",
		"clut": 0,
		"sequence": 8,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": "player blood splash",
		"collection": "Projectiles",
		"clut": 0,
		"sequence": 10,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": "civilian blood splash",
		"collection": "Bob",
		"clut": 0,
		"sequence": 7,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": "fighter melee detonation",
		"collection": "Pfhor Fighter",
		"clut": 0,
		"sequence": 11,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": false,
			"end_when_transfer_animation_loops": false,
			"sound_only": true,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	{
		"name": "fighter projectile detonation",
		"collection": "Pfhor Fighter",
		"clut": 0,
		"sequence": 10,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": "compiler bolt minor detonation",
		"collection": "Compiler",
		"clut": 0,
		"sequence": 6,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	{
		"name": "compiler bolt major detonation",
		"collection": "Compiler",
		"clut": 1,
		"sequence": 6,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	{
		"name": "compiler bolt major contrail",
		"collection": "Compiler",
		"clut": 1,
		"sequence": 5,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": "metallic clang",
		"collection": "Projectiles",
		"clut": 0,
		"sequence": 23,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": false,
			"end_when_transfer_animation_loops": false,
			"sound_only": true,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	
	{
		"name": "teleport object in",
		"collection": "Items",
		"clut": 0,
		"sequence": 0,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": false,
			"end_when_transfer_animation_loops": true,
			"sound_only": false,
			"make_twin_visible": true,
			"media_effect": false
		},
		"delay": 30,
		"delay_sound": "teleport in"
	},
	{
		"name": "teleport object out",
		"collection": "Items",
		"clut": 0,
		"sequence": 0,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": false,
			"end_when_transfer_animation_loops": true,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
	
	{
		"name": "glass breaking", # TODO: add this for breaking bottles
		"collection": "Scenery (Water)",
		"clut": 0,
		"sequence": 22,
		"sound_pitch": 1.0,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false,
			"media_effect": false
		},
		"delay": 0,
		"delay_sound": null
	},
]

