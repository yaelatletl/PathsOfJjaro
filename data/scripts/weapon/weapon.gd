extends Node
class_name Weapon

var spark = load("res://data/scenes/spark.tscn")
var trail = load("res://data/scenes/trail.tscn")
var decal = load("res://data/scenes/decal.tscn")


var damage_type : int = Pooling.DAMAGE_TYPE.KINECTIC
var firerate : float
var spatial_parent : Node = null
var gun_name : String
var bullets : int #sync
var ammo : int #sync
var max_bullets : int
var damage : int
var reload_speed : float
var default_fov : float = 100
var zoom_fov : float = 40
var uses_randomness : bool = false
	
var max_range : float = 200
var spread_pattern : Array = []
var spread_multiplier : float = 0
var max_random_spread_x = 1.0
var max_random_spread_y = 1.0
	
# Get effect node
var effect = null
var anim = null
var animc = null
var mesh = null	
var ray = null
var audio = null

var original_cast_to = Vector3.FORWARD
var shooting_cooldown = false

var actor = null

func _ready():
	if uses_randomness:
		randomize()
	if spatial_parent == null:
		printerr("spatial_parent must be set before adding to scene")
		return
	update_spatial_parent_relatives(spatial_parent)

func check_relatives() -> bool:
	if spatial_parent == null:
		return false
	if anim == null:
		return false
	if animc == null:
		return false
	if mesh == null:	
		return false
	if effect == null:
		return false
	if ray == null:
		return false
	if audio == null:
		return false
	return true

func update_spatial_parent_relatives(spatial_parent) -> bool:
	# Get animation node
	anim = spatial_parent.get_node_or_null(gun_name+"/mesh/anim")
	print(anim)
	mesh = spatial_parent.get_node_or_null(gun_name)
	effect = spatial_parent.get_node_or_null(gun_name+"/effect")
	
	ray = spatial_parent.get_node(gun_name+"/ray")
	print(ray)
	# Get current animation
	if anim == null:
		return false
	animc = anim.current_animation
	
	if ray is RayCast3D:
		ray.set_meta("original_cast_to", ray.target_position)
	audio = spatial_parent.get_node(gun_name+"/audio")
	#if spread_pattern.size() > 0:
	setup_spread(spread_pattern, spread_multiplier, max_range)
	actor = spatial_parent.get_parent()
	return true


func setup_spread(spread_pattern, spread_multiplier, max_range = 200, separator_name = "") -> void:
	var separator
	var parent = ray
	if ray is RayCast3D:
		#Setup main range
		ray.target_position.z = -max_range
		ray.set_meta("original_cast_to", ray.target_position)
		original_cast_to = ray.target_position
		print("set target position to: ", ray.target_position, "from gun: ", gun_name)

	if separator_name != "":
		separator = Marker3D.new()
		separator.name = separator_name
		if not ray:
			print("ray is null at ", gun_name, " in ", get_path(), " separator_name:", separator_name)
		ray.add_child(separator)
		parent = separator
	
	for point in spread_pattern:
		var new_cast = RayCast3D.new()
		new_cast.enabled = true
		new_cast.target_position.x = point.x * spread_multiplier 
		new_cast.target_position.y = point.y * spread_multiplier 
		new_cast.target_position.z = -max_range
		new_cast.set_meta("original_cast_to", new_cast.target_position)
		parent.add_child(new_cast)

func _draw() -> void:
	if not check_relatives():
		return
	# Check is visible
	if not mesh.visible:
		# Play draw animaton
		anim.play("Draw")
	
func _hide() -> void:
	if not check_relatives():
		return
	# Check is visible
	if mesh.visible:
		# Play hide animaton
		anim.play("Hide")
	
func _sprint(sprint, _delta) -> void:
	if not check_relatives():
		return
	if sprint and spatial_parent.actor.direction:
		mesh.rotation.x = lerp(mesh.rotation.x, -deg_to_rad(40), 5 * _delta)
	else:
		mesh.rotation.x = lerp(mesh.rotation.x, 0.0, 5 * _delta)

func shoot(delta) -> void: #Implemented as a virtual method, so that it can be overriden by child classes
	_shoot(self, delta, bullets, max_bullets, ammo, reload_speed, firerate, "", "ammo", "bullets", true)


func _shoot(node_in, _delta, l_bullets, l_max_bullets, l_ammo, l_reload_speed, l_firerate, relative_node = "", ammo_name ="ammo", bullets_name = "bullets",tied_to_animation = true) -> void:
	if not check_relatives():
		if spatial_parent!= null:
			update_spatial_parent_relatives(spatial_parent)
		return
	var can_shoot = true
	if tied_to_animation:
		can_shoot = animc != "Shoot" 
	else:
		can_shoot = not shooting_cooldown
	if l_bullets > 0:
		# Play shoot animation if not reloading
		if can_shoot and animc != "Reload" and animc != "Draw" and animc != "Hide":
			node_in.set_deferred(bullets_name, l_bullets - 1)
			Gamestate.set_in_all_clients(node_in, bullets_name, l_bullets)
			# recoil
			spatial_parent.camera.rotation.x = lerp(spatial_parent.camera.rotation.x, randf_range(1, 2), _delta)
			spatial_parent.camera.rotation.y = lerp(spatial_parent.camera.rotation.y, randf_range(-1, 1), _delta)
			
			# Shake the camera
			spatial_parent.camera.shake_force = 0.002
			spatial_parent.camera.shake_time = 0.2
			
			# Change light energy
			effect.get_node("shoot").light_energy = 2
			
			# Emitt fire particles
			effect.get_node("fire").emitting = true
			
			# Emitt smoke particles
			effect.get_node("smoke").emitting = true
			
			# Play shoot sound
			audio.get_node("shoot").pitch_scale = randf_range(0.9, 1.1)
			audio.get_node("shoot").play()
			
			var anim_speed = l_firerate

			# Play shoot animation using firate speed
			if tied_to_animation:
				anim.play("Shoot", 0, anim_speed)
			
			# Get raycast weapon range
			_shoot_cast(relative_node, _delta)
			if not tied_to_animation:
				shooting_cooldown = true
				anim_speed = anim.get_animation("Shoot").length / l_firerate
				await get_tree().create_timer(anim_speed).timeout
				shooting_cooldown = false
	else:
		# Play out sound
		if not audio.get_node("out").playing:
			audio.get_node("out").pitch_scale = randf_range(0.9, 1.1)
			audio.get_node("out").play()
		if GlobalSettings.auto_reload:
			_reload(node_in, l_bullets, l_max_bullets, l_ammo, ammo_name, bullets_name, l_reload_speed)

func _shoot_cast(relative_node="", delta=0) -> void: 
	shoot_raycast(uses_randomness, max_random_spread_x, max_random_spread_y, max_range, relative_node)

func shoot_raycast(uses_randomness, max_random_spread_x, max_random_spread_y, max_range, relative_node = "") -> void:
	if not check_relatives():
		return
	var local_ray = self.ray
	if relative_node != "":
		local_ray = ray.get_node(relative_node)
		if local_ray.get_children().size() <= 0:
			local_ray = self.ray
	if local_ray is Marker3D:
		#Handle more than one raycast 
		for child_ray in local_ray.get_children():
			if child_ray is RayCast3D:
				# Get raycast range
				make_ray_shoot(child_ray, uses_randomness, max_random_spread_x, max_random_spread_y, max_range)
							
				# Check raycast is colliding
	elif local_ray is RayCast3D:
		# Get raycast range
		make_ray_shoot(local_ray, uses_randomness, max_random_spread_x, max_random_spread_y, max_range)

func make_ray_shoot(ray : RayCast3D, uses_randomness, max_random_spread_x, max_random_spread_y, max_range) -> void:
	if not check_relatives():
		return
	
	if uses_randomness:
		ray.target_position.x = max_random_spread_x* randf_range(-ray.target_position.z/2, ray.target_position.z/2)
		ray.target_position.y = max_random_spread_y* randf_range(-ray.target_position.z/2, ray.target_position.z/2)
		ray.target_position.z = -max_range
	if ray.is_colliding():
		# Get barrel node
		var barrel = spatial_parent.get_node(gun_name+"/barrel")
		# Get main scene
		var main = spatial_parent.get_tree().get_root().get_child(0)
				
		# Create a instance of trail scene
		var local_trail = trail.instantiate()
		# Change trail position to out of barrel position
		main.add_child(local_trail)
		local_trail.global_transform.origin = barrel.global_transform.origin
		
		# Add the trail to main scene
		# Change trail rotation to match bullet hit
		#TODO: Show trails even if the bullet doesn't hit anything
		local_trail.look_at(ray.get_collision_point(),Vector3(0, 1, 0))

		var local_damage = int(randf_range(damage/1.5, damage))
		
		# Do damage
		if ray.get_collider() is RigidBody3D:
			ray.get_collider().apply_central_impulse(-ray.get_collision_normal() * (local_damage * 0.3))
		
		if ray.get_collider().is_in_group("prop"):
			if ray.get_collider().is_in_group("metal"):
				var local_spark = spark.instantiate()
				
				# Add spark scene in collider
				ray.get_collider().add_child(local_spark)
					
				# Change spark position to collider position
				local_spark.global_transform.origin = ray.get_collision_point()
				
				local_spark.emitting = true
			
		if ray.get_collider().has_method("_damage"):
			ray.get_collider()._damage(local_damage, damage_type)
		
		# Create a instance of decal scene
		var local_decal = decal.instantiate()
		
		# Add decal scene in collider
		ray.get_collider().add_child(local_decal)
		
		# Change decal position to collider position
		local_decal.global_transform.origin = ray.get_collision_point()
		
		# decal spins to collider normal
		local_decal.look_at(ray.get_collision_point() + ray.get_collision_normal(), Vector3(1, 1, 0))
	if not uses_randomness:
		if ray.get_meta("original_cast_to") != null:
			ray.target_position = ray.get_meta("original_cast_to")


func reload() -> void:
	if not check_relatives():
		if spatial_parent!= null:
			update_spatial_parent_relatives(spatial_parent)
		return
	_reload(self, bullets, max_bullets, ammo, "ammo", "bullets", reload_speed)


func _reload(node_in, bullets, max_bullets, ammo, ammo_variable_name, bullets_variable_name, reload_speed) -> void:
	if bullets < max_bullets and ammo > 0:
		if animc != "Reload" and animc != "Shoot" and animc != "Draw" and animc != "Hide":
			# Play reload animation
			anim.play("Reload", 0.2, reload_speed)
			for b in range(0, ammo):
				bullets += 1
				ammo -= 1
				node_in.set_deferred(bullets_variable_name, bullets)
				node_in.set_deferred(ammo_variable_name, ammo)
				
				if bullets >= max_bullets:
					break
			Gamestate.set_in_all_clients(node_in, ammo_variable_name, ammo)

func _zoom(input, _delta) -> void:
	if not check_relatives():
		if spatial_parent!= null:
			update_spatial_parent_relatives(spatial_parent)
		return
	make_zoom(input, _delta)

func make_zoom(input, _delta) -> void:
	var lerp_speed : int = 30
	var camera = spatial_parent.camera
	
	if input and animc != "Reload" and animc != "Hide" and animc != "Draw":
		camera.fov = lerp(camera.fov, zoom_fov, lerp_speed * _delta)
		mesh.position.y = lerp(mesh.position.y, 0.001, lerp_speed * _delta)
		mesh.position.x = lerp(mesh.position.x, -0.088, lerp_speed * _delta)
	else:
		camera.fov = lerp(camera.fov, default_fov, lerp_speed * _delta)
		mesh.position.y = lerp(mesh.position.y, 0.0, lerp_speed * _delta)
		mesh.position.x = lerp(mesh.position.x, 0.0, lerp_speed * _delta)
	
func _update(_delta) -> void:
	if not check_relatives():
		if spatial_parent!= null:
			update_spatial_parent_relatives(spatial_parent)
		return
	if animc != "Shoot":
		if spatial_parent.arsenal.values()[spatial_parent.current] == self:
			spatial_parent.camera.rotation.x = lerp(spatial_parent.camera.rotation.x, 0.0, 10 * _delta)
			spatial_parent.camera.rotation.y = lerp(spatial_parent.camera.rotation.y, 0.0, 10 * _delta)
	
	# Get current animation
	animc = anim.current_animation
	
	# Change light energy
	effect.get_node("shoot").light_energy = lerp(effect.get_node("shoot").light_energy, 0.0, 5 * _delta)
	
	# Remove recoil
	mesh.rotation.x = lerp(mesh.rotation.x, 0.0, 5 * _delta)

func add_ammo(ammo_in):
	ammo += ammo_in
	Gamestate.set_in_all_clients(self, "ammo", ammo)
