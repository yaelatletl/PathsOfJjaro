# basic item spawner
# place in scene and then select either "ammo", "powerup", or "weapon".



extends Node
#var id = 0
#var type = "none"


enum spawn_a {ammo, weapon, object}
export (spawn_a) var spawn

enum if_weapon {magnum, ma75, fusion_pistol, flame_thrower, rocket_launcher}
export (if_weapon) var weapon_type

enum if_ammo {magnum_rounds, ma75_rounds, ma75_grenades, fusion_cell, napalm, rockets}
export (if_ammo) var ammo_id

enum if_object {chip, padd, overshield, invincible, invisible}
export (if_object) var object_id


export var spawn_on_ground = false
export var teleport_in = false
export var amount = 1


# stores the location of guns
var ma75 = load("res://BaseGD/Guns/ma75.tscn")
var fpistol = load("res://BaseGD/Guns/fusion_pistol.tscn")
var magnum = load("res://BaseGD/Guns/magnum.tscn")
var tozt = load("res://BaseGD/Guns/magnum.tscn")
var spnkr = load("res://BaseGD/Guns/magnum.tscn")
var smg = load("res://BaseGD/Guns/magnum.tscn")

var weapons = [magnum, ma75, fpistol, tozt, spnkr,smg]


# stores the location of gun objects
var ma75o = load("res://BaseGD/Guns/ma75_object.tscn")
var fpistolo = load("res://BaseGD/Guns/fusion_object.tscn")
var magnumo = load("res://BaseGD/Guns/magnum_object.tscn")
var tozto = load("res://BaseGD/Guns/tozt_object.tscn")
var spnkro = load("res://BaseGD/Guns/spnkr_object.tscn")
var smgo = load("res://BaseGD/Guns/magnum.tscn")

var weapon_objects = [magnumo, ma75o, fpistolo, tozto, spnkro,smgo]

# stores the location of ammo objects.
var ma75_rounds = load("res://BaseGD/Guns/ma75_rounds.tscn")
var ma75_grenades = load("res://BaseGD/Guns/ma75_grenades.tscn")
var magnum_rounds = load("res://BaseGD/Guns/magnum_rounds.tscn")
var spnkr_missiles = load("res://BaseGD/Guns/SPNKR_missiles.tscn")
var tozt_can = load("res://BaseGD/Guns/ma75.tscn")
var fp_cell = load("res://BaseGD/Guns/fp_cell.tscn")

var ammo = [magnum_rounds, ma75_rounds, ma75_grenades, fp_cell, tozt_can, spnkr_missiles]

# store location of powerup meshes
var overshield = load("res://BaseGD/Guns/ma75.tscn")
var nightvision = load("res://BaseGD/Guns/ma75.tscn")
var invisibility = load("res://BaseGD/Guns/ma75.tscn")

var powerups = [overshield, nightvision, invisibility]

func _ready():
	spawn()



func spawn():
	$placeholder_cone.set_visible(false)
	#print("weapon type is: ", weapon_type)
	for i in range(amount):
		
		if spawn == 0:
			var shown_object = ammo[ammo_id]
			shown_object = shown_object.instance()
			shown_object.set_as_toplevel(true)
			$drop.get_parent().add_child(shown_object)
			

		if spawn == 1:
			var shown_object = weapon_objects[weapon_type]
			#print("weapon_objects: ", weapon_objects)
			#print("shown object: ", shown_object)
			shown_object = shown_object.instance()
			shown_object.set_as_toplevel(true)
			$drop.get_parent().add_child(shown_object)

		if spawn == 2:
			var shown_object = powerups[object_id]
			shown_object = shown_object.instance()
			shown_object.set_as_toplevel(true)
			$drop.get_parent().add_child(shown_object)
	
	#queue_free()


