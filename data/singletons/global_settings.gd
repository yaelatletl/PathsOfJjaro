extends Node

var auto_reload = true
var default_tags = {
	"follower" : "res://assets/weapons/tags/follower.json",
	"zeus": "res://assets/weapons/tags/zeus.json",
	"alien_gun" : "res://assets/weapons/tags/alien_gun.json",
	"ma75b" : "res://assets/weapons/tags/ma75b.json",
	# Create mk 23 using weapon classs
	"mk_23" : "res://assets/weapons/tags/mk_23.json",
	# Create glock 17 using weapon class
	"glock_17" : "res://assets/weapons/tags/glock_17.json",
	# Create glock 17 using weapon class
	"shotgun" : "res://assets/weapons/tags/shotgun.json",
	# Create kriss using weapon class
	"kriss" : "res://assets/weapons/tags/kriss.json",
}

var default_view_models = {
	"follower" :  "res://assets/weapons/models/generic_pistol_scene.tscn", 
	"zeus" : "res://assets/weapons/models/generic_pistol_scene.tscn",
	"alien_gun" : "res://assets/weapons/models/generic_pistol_scene.tscn",
	"ma75b" : "res://assets/weapons/models/generic_kriss_scene.tscn",
	"mk_23" : "res://assets/weapons/models/generic_pistol_scene.tscn",
	"glock_17" : "res://assets/weapons/models/generic_pistol_scene_2.tscn",
	"shotgun" : "res://assets/weapons/models/generic_kriss_scene.tscn",
	"kriss" : "res://assets/weapons/models/generic_kriss_scene.tscn"
}
