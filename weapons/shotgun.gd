extends RaycastWeapon
export(PackedScene) var squib = preload("res://Basics/Guns/squib.tscn")

export var spread = 2



func _ready():
	$AnimationPlayer.play("standard")
	identity = "WSTE-M5 Combat Shotgun"
	in_magazine = 1
	in_secondary_magazine = 1
	primary_magazine_size = 1
	secondary_magazine_size = 1
	primary_ammo_id = 7
	secondary_ammo_id = 7

func dual_wield():
	dual_wielding = true
	$AnimationPlayer.play("dual_start")

func primary_fire():

	#check if the weapon has cooled
	if can_shoot:

		# adjust ray for random spread


		# check if there is ammo in the magazine
		if ammo_check_primary():

			randomshoot()
			# check for collisions
			var hit = $aperture/RayCast.get_collider()

			# if a collision occurs
			if hit:
				# if the object is a static or kinematic body
				if hit is StaticBody or hit is KinematicBody:

					# load a squib (a spark or flash to show impact) and place it at the impact point
					var squibpoint = $aperture/RayCast.get_collision_point()
					var thissquib = squib.instance()
					thissquib.set_as_toplevel(true)
					var squibpos = thissquib.get_global_transform()
					squibpos.origin = squibpoint
					thissquib.set_global_transform(squibpos)
					hit.owner.add_child(thissquib)

			# weapon set not chambered, start timer for cooldown.
			$AnimationPlayer.play("fire")
			can_shoot=false
			$chamber_timer.start()


func _on_chamber_timer_timeout():
	can_shoot = true

# "M .75 ammunition is neither vacuum enabled nor teflon coated, and due to a manufacturing defect is highly inaccurate at long range."
# used for random spread.
func randomshoot():

	randomize()
	var randx = rand_range(-spread, spread)
	randomize()
	var randy = rand_range(-spread, spread)


	var newx = 0 + randx
	var newy = 0 + randy
	#print("rando =", newx," ", newy)
	$aperture/RayCast.set_cast_to(Vector3(newx,newy,-1000))


func _on_grenade_timer_timeout():
	can_shoot_secondary = true
	pass # replace with function body
