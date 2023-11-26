extends StaticBody3D # static body should sufficient for projectiles; TO DO: grenades need gravity applied

# Projectile.gd


# TO DO: can/should Trooper use a shoulder-mounted launcher to fire its grenades? that would make the Trooper's rifle look and behave less like the player's AR - it could also use a different bullet effect (similar to M1's alien gun) for added 'alien-ness'; a shoulder-mounted launcher would also be consistent with Hunter (shoulder-mounted energy weapon) and Juggernaut (shoulder-mounted rocket launchers) designs for a more unified-looking bestiary (the Trooper's body armor could be revised to look more like Hunter's chest armor, so that Fighter -> Trooper -> Hunter designs have a logical progression from minimal to medium to full armor - plus it allows mesh reuse)



var projectile_type: Constants.ProjectileType
var explosion_type:  Constants.DetonationType

var damage := 10
var speed := 10.0 #00.0
var lifetime := 10.0 # TO DO: should all projectiles have a max lifetime, after which they detonate/free? (it shouldn't be necessary as walls should stop anything from escaping but might be handy during testing/debugging)



var __vector: Vector3


func _ready():
	get_tree().create_timer(lifetime).connect("timeout", Callable(self, "queue_free"))



# note: shooter is only used for collision exception and origin and direction are passed separately so Projectile class can be used by NPCs (which have a different aiming mechanism) as well as Player (which uses camera rotation to aim); caller is responsible for calculating the projectile's point of origin as an offset from its global_position; direction is a global_rotation
func configure_and_shoot(projectile_type: Constants.ProjectileType, projectile_origin: Vector3, direction: Vector3, shooter: PhysicsBody3D) -> void: # TO DO: WeaponTrigger.configure() needs to look up the projectile's settings, which may be a Dictionary or ProjectileDefinition created from a dictionary of parameters (c.f. Weapon)
	add_collision_exception_with(shooter)
	global_position = projectile_origin
	# TO DO: projectiles that have a solid form (grenade, rocket; any others?) will need to set their rotation as well so the 3D mesh points in correct direction; OTOH bullets have no visible shape and 2D billboard sprites are best for energy bolts; flamethrower will require some experimentation to find the right look (possibly a mixture of sphere meshes, materials, and sprites); however we only need bullets and energy bolts for Arrival Demo so can ignore 3D projectiles and flame for now
	__vector = direction * speed


func _physics_process(delta):
	var col = move_and_collide(__vector * delta)
	if col:
		print("Projectile hit: ", col.get_collider().get_parent().name)
		# TO DO: trigger Detonation
		queue_free()
	

