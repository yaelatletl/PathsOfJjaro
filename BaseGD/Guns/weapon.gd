# This script attempts to unify the base behaviours of all weapons.
# it is extended by each weapon to facilitate their specific functions
# for example: the fusion pistol is a projectile weapon that has overload events, the pistol can be dual wielded.
#class_type Weapon
extends Node

# sets the readiness of the weapon to fire
var can_shoot = true
var can_shoot_secondary = true

# if homing sets target
var target = null 

# the folloiwing variables handle basic naming and flavor.
var identity = "default weapon"
var description = "basic weapon, no real info yet"

# stores various parameters for the weapon
var id = 0 # unique weapon id, 0 for default
var primary_ammo_id = 0 # kind of ammo for primary fire
var secondary_ammo_id = 0 # kind of ammo for secondary fire
var in_magazine = 0 # how much ammo we have in the gun (not total ammo)
var in_secondary_magazine = 0# how much secondary ammo we have in the gun (not total ammo)
var primary_magazine_size = 0 # how much ammo the primary magazine canhold.
var secondary_magazine_size = 0 # how much ammo the secondary magazine canhold.



var wielder

export var dual_wieldable = false
var dual_wielding = false

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func setup(wieldee):
	wielder = wieldee
	
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func primary_fire():
	pass
	
func secondary_fire():
	pass
	
func secondary_release():
	pass

# Reloads the weapon from the wielders inventory when called.
func reload_primary():
	
	# retrieves the number of reloads the player has for this weapon in their inventory
	var ammo = wielder.inventory[primary_ammo_id]
	
	if ammo > 0:
		# reload the weapons magazine
		in_magazine = primary_magazine_size
		# remove 1 reload from the players infentory
		wielder.inventory[primary_ammo_id] -= 1

func reload_secondary():
	var ammo = wielder.inventory[secondary_ammo_id]
	
	if ammo > 0:
		in_secondary_magazine = secondary_magazine_size
		wielder.inventory[secondary_ammo_id] -= 1


func ammo_check_primary(size = 1):
	if in_magazine >= size:
		in_magazine -= size
		return true
	else:
		reload_primary()
		return false
	

func ammo_check_secondary(size = 1):
	if in_secondary_magazine >= size:
		in_secondary_magazine -= size
		return true
	else:
		reload_secondary()
		return false
	
	
func dual_wield():
	
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
