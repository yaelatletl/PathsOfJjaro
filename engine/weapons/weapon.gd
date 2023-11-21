extends Node
class_name Weapon


# TO DO: for function naming convention, use single leading underscore for Godot event handlers (_ready, _on_area_foo_entered), use double underscores for private functions and vars; do NOT use leading underscores on public properies and methods


# Weapon.gd -- managed by weapon_manager.gd, this represents one of the weapons available to Player in the game and holds that weapon's current state (ammo supply and current behavior) and WeaponInHand view object 

# WeaponInHand.tscn provides a weapon's visible in-hand representation: the meshes, sounds, etc for a particular weapon type - fist, pistol, fusion_gun, shotgun, assault_rifle, flechette_gun, missile_lancher, flamethrower, alien_gun - plus animation player and a standard API for triggering those animations, which Weapon's state machine calls on transitions)


class WeaponTrigger: pass


var primaryTrigger: WeaponTrigger
var secondaryTrigger: WeaponTrigger # TO DO: may be null, in which case should it share the same instance as primaryTrigger? (in case of dual-wield weapons, the WeaponTrigger still needs to know if primary or secondary trigger is pulled as that determines which side fires first)



# TO DO: eliminate projectile-specific code


# note: like single-wield weapons (fusion, AR, SPNKR, flamethrower), dual-wield weapons (fist, pistol, shotgun) are represented by a *single* Weapon instance


# TO DO: Weapon's state machine may be a bit awkward to implement as most dual-trigger weapons tie the two triggers together behaviorally, whereas AR allows both triggers to operate independently [except when reloading]; probably another reason why Classic's Weapon physics has weaponClass property (I've not checked the AO source but I expect M2's WiH functions contain lots of `switch (weaponClass) {...}` blocks); if it's a PITA to implement all behaviors in a single class then define concrete subclasses corresponding to each M2 weaponClass:
#
# melee -- fist (this is basically dual_wield but firing a higher-damage projectile when sprinting)
# dual_wield -- pistol, shotgun (if player has only one of these weapon items in inventory, only one is shown on screen and can be fired by either trigger key)
# dual_purpose -- fusion pistol (basically multipurpose except only one trigger can be used at a time and both share the same Magazine)
# multipurpose -- assault_rifle, alien_gun (Q. what is difference between alien gun's primary and secondary firing behaviors, and what does it do when both triggers are pressed at same time? also, alien Magazine is shared between both triggers)
# normal -- rocket_launcher, flamethrower, flechette_gun (single firing mode; either trigger key fires)
#



var spatial_parent : Node = null

var gun_name : String

# TO DO: get rid of these (Mthon weapons do not have telescopic zoom and it would change gameplay to add them)
var default_fov : float = 100
var zoom_fov : float = 40

var damage : int # this belongs on Projectile which passes it to Explosion
var max_range : float = 200 # this belongs on Projectile 

var reload_speed : float


var firerate : float
var ammo : int #sync # ammo type
var bullets : int #sync # remaining
var max_bullets : int
var uses_randomness : bool = false # rename has_random_ammo; used by alien weapon, which also removes itself from inventory when exhausted


var spread_pattern : Array = []
var spread_multiplier : float = 0
var max_random_spread_x = 1.0
var max_random_spread_y = 1.0


# Get effect node # TO DO: get rid of these; there should be a single res://assets/weapons/WEAPON_NAME dir containing WEAPON_IN_HAND.tscn and all its related assets (the same dir can also contain the WEAPON_ITEM.tscn); that scene is instantiated and stored in a single weapon_in_hand property here and all WiH scenes implement a standard API that Weapon calls to perform the weapon's actions
var effect = null
var anim = null
var animc = null
var mesh = null	
var ray = null
var audio = null

var original_cast_to = Vector3.FORWARD # what does this do?

var shooting_cooldown = false # TO DO: replace this with state machine that controls transitions between weapon states; note that dual-Trigger weapons may allow some trigger states to operate independently (e.g. assault rifle triggers fire independently whereas fusion triggers are interlocked); M2 weapons physics has a weaponClass property that dictates how dual triggers can/cannot interact

var actor = null # presumably Player instance, but it's assigned via unnecessarily complicated process

func _ready():
	if spatial_parent == null:
		printerr("spatial_parent must be set before adding to scene")
		return
	update_spatial_parent_relatives(spatial_parent)



func set_weapon_definition(data: Dictionary) -> void:
	pass

	#self.spatial_parent = weapon_parent
	
	self.ammo = data.ammo # TO DO: get rid of this: Player should hold all inventory and Weapon should request ammo from Player when attempting to reload itself
	
	# TO DO: there is some awkwardness in M2's ammo management when dealing with fusion pistol, as it shares a single magazine between both triggers (other dual-trigger weapons use a separate mag for each trigger); simplest solution might be to implement a Magazine class, which holds bullets and max_bullets, a single instance of which can be shared between both triggers when needed
	
	self.gun_name = data.name
	self.firerate = data.fireRate
	self.bullets = data.bullets
	self.max_bullets = data.maxBullets # capacity
	self.damage = data.damage
	self.reload_speed = data.reloadSpeed
	self.uses_randomness = bool(data.randomness)
	
	
#	self.spread_pattern = parse_spread_pattern(data.spreadPattern)
	self.spread_multiplier = data.spreadMultiplier
	self.max_random_spread_x = data.randomSpread[0]
	self.max_random_spread_y = data.randomSpread[1]
	#self.zoom_fov = data.defaultZoomFOV
	self.max_range = data.range










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



# TO DO: fix this: Weapon receives trigger inputs from Player (trigger inputs need to be read by player so they can be intercepted/disabled when player is dead/teleporting/etc); therefore, Weapon needs shoot_primary and shoot_secondary methods which call the corresponding WeaponTrigger (these calls must go via a `match weaponClass` block or state machine that ensures correct interlocking behavior)

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
		_reload(node_in, l_bullets, l_max_bullets, l_ammo, ammo_name, bullets_name, l_reload_speed)


func _shoot_cast(relative_node="", delta=0) -> void: 
	pass # TO DO: delete; there is no need for raycast ("raygun") firing mode - just use Projectile for everything (this includes fists, which fire a very short-range projectile)



# TO DO: the Weapon's state machine should detect when primary or secondary WeaponTrigger is out of ammo and perform primaryReload/secondaryReload or removeFromInventory/switchToPrevious

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


func add_ammo(ammo_in): # TO DO: get rid of this: ammos are stored on Player along with other inventory items; Weapon should request ammo from Player
	ammo += ammo_in

