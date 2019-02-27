# This script determines the behaviours of the fusion pistol weapon (not the item laying on the ground)

extends "res://BaseGD/Guns/weapon.gd"
export(PackedScene) var Fusion_Bolt = preload("res://BaseGD/Guns/fusion_bolt.tscn")
export(PackedScene) var Charged_Fusion_Bolt = preload("res://BaseGD/Guns/charged_fusion_bolt.tscn")
var charged = false
var charging = false
func _process(delta):
	print(charged, charging)
		
func _ready():
	identity = "Zeus Class Fusion Pistol"
	in_magazine = 100
	primary_magazine_size = 100
	primary_ammo_id = 3
# when primary fire is called
func primary_fire():
	# check to see if we have ammo.

		# if the can_shoot variable is true
		if can_shoot:
			if ammo_check_primary(5):
				# load a bolt as an instance
				var bolt = Fusion_Bolt.instance()
				bolt.setup(wielder)
				# add the bolt to the aperture of the fusion pistol
				#$aperture.add_child(bolt)
				bolt.set_global_transform($aperture.get_global_transform())
				get_node("/root").add_child(bolt)
				# toggle can shoot (to avoid spawning a bolt per cycle)
				can_shoot=false
				
				# trigger the cool down timer.
				$Timer.start()

func secondary_fire():
	if charging == false:
		$charge.start()
		charging = true

func secondary_release():
	if charged:
		if can_shoot:
			if ammo_check_primary(25):
				# load a bolt as an instance
				var bolt = Charged_Fusion_Bolt.instance()
				
				# add the bolt to the aperture of the fusion pistol
				bolt.set_global_transform($aperture.get_global_transform())
				get_node("/root").add_child(bolt)
				
				# toggle can shoot (to avoid spawning a bolt per cycle)
				can_shoot=false
				
				# trigger the cool down timer.
				$Timer.start()
				charged = false
				charging = false
	else:
		charging = false
		charged = false
		$charge.stop()
		

	
# when the cooldown timer has elapsed
func _on_Timer_timeout():
	# reset the canshoot variable.
	can_shoot = true


func _on_charge_timeout():
	charged = true
	$overload.start()



func _on_overload_timeout():
	pass # replace with function body
