extends Weapon
class_name ProjectileWeapon 


# TO DO: delete this file

var projectile_type
var camera = null

# TO DO: use composition, not subclassing

func set_projectile(type):
	projectile_type = type

func _shoot_cast(relative_node = "", delta=0)->void:
	shoot_projectile(relative_node)


# TO DO: aiming and firing projectiles is the Player's job; the Weapon[Trigger] just tells it what type of projectile to shoot and its origin's offset relative to Player's center

func shoot_projectile(separator_name = "")->void:
	var active = ray
	if separator_name != "":
		active = ray.get_node(separator_name)
	var barrel = spatial_parent.get_node("{}/barrel".format([gun_name], "{}"))
	if active is Marker3D or active is RayCast3D:
		#Handle more than one raycast 
		for child_ray in active.get_children():
			if child_ray is RayCast3D:
				make_projectile_shoot(child_ray.global_transform.origin, child_ray.target_position)
		if active.get_children().size() == 0:
			make_projectile_shoot(barrel.global_transform.origin, Vector3.ZERO)	
	if active is RayCast3D:
		# Shoot form main barrel 
		make_projectile_shoot(barrel.global_transform.origin, ray.target_position)
	
func make_projectile_shoot(origin, offset):
	if actor == null:
		actor = spatial_parent.get_parent()
	if camera == null:
		camera = spatial_parent.head.get_node("neck").get_node("camera")
	offset = Vector3(offset.x, offset.y, 0)
	var direction = camera.to_global(Vector3.ZERO) - camera.to_global(Vector3(0,0,100) + offset)
	# Add the projectile to the scene through pooling
	Pooling.add_projectile(projectile_type, origin, direction, actor) 
