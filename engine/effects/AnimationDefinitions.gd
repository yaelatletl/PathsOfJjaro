extends Node



const ANIMATION_DEFINITONS := [
	{
		"name": Enums.AnimationType.GRENADE_CONTRAIL,
		"flags": {
			"end_when_animation_loops": true,
			"end_when_transfer_animation_loops": false,
			"sound_only": false,
			"make_twin_visible": false, # only true for TELEPORT_OBJECT_IN; probably don't need it
			"media_effect": false, # TO DO: true for liquid splash effects only;
		},
		"delay": 0,
		"delay_sound": null,
	},
	
]

