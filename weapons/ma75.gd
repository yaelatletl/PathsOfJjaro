extends Weapon

export(PackedScene) var Projectile = preload("res://assets/weapons/grenade.tscn")
export(PackedScene) var squib = preload("res://Basics/Guns/squib.tscn")

export var spread = 20


func _ready():
	identity = "M.75 Assault Rifle/Grenade Launcher"
	in_magazine = 52
	in_secondary_magazine = 7
	primary_magazine_size = 52
	secondary_magazine_size = 7
	primary_ammo_id = 1
	secondary_ammo_id = 2
	
func primary_fire():
	
	#check if the weapon has cooled
	if can_shoot:

		# check if there is ammo in the magazine
		if ammo_check_primary():
			
			# adjust ray for random spread
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
			can_shoot=false
			$chamber_timer.start()

func secondary_fire():
	if can_shoot_secondary:
		if ammo_check_secondary():
				# load a bolt as an instance
				var bolt = Projectile.instance()
				bolt.setup(wielder)
				# add the bolt to the aperture of the fusion pistol
				#$aperture.add_child(bolt)
				bolt.set_global_transform($grenade.get_global_transform())
				get_node("/root").add_child(bolt)
				# toggle can shoot (to avoid spawning a bolt per cycle)
				can_shoot_secondary = false
				
				# trigger the cool down timer.
				$grenade_timer.start()
	
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
	$aperture/RayCast.set_cast_to(Vector3(newx,newy,-100))


func _on_grenade_timer_timeout():
	can_shoot_secondary = true
	pass # replace with function body
