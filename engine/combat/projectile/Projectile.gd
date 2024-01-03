extends StaticBody3D # static body should sufficient for projectiles; TODO: grenades need gravity applied

# engine/actors/projectiles/Projectile.gd


# TODO: if the projectile is affected by gravity, how best to apply a level's gravity? while we could define `Global.level_gravity`, it may be cleaner to define `Projectile.gravity` and when Player enters a level tell the ProjectileManager to iterate its ProjectileClasses and set each `ProjectileClass.level_gravity = LevelManager.current_level.gravity`, which will multiply by the projectile's own influenced-by-gravity multiplier to get the velocity.y delta to apply in each Projectile._physics_process



var __projectile_class: ProjectileManager.ProjectileClass # the class of this projectile



var speed := 10.0 #00.0
var lifetime := 10.0 # TODO: should all projectiles have a max lifetime, after which they detonate/free? (it shouldn't be necessary as walls should stop anything from escaping but might be handy during testing/debugging)



var __vector: Vector3


func _ready():
	get_tree().create_timer(lifetime).connect(&"timeout", queue_free)


# note: `shooter` parameter is only used for collision exception; origin and direction are passed separately so Projectile class can be used by Player (which uses camera rotation to aim) and by NPCs (which use a different mechanism for aiming)
#
# note: caller should calculate the projectile's point of origin as an offset from its global_position
#
# note: direction is a global_rotation; for Player, this is calculated from camera's look vector; for NPCs, this is calculated by their own target acquisition logic (e.g. identify the nearest hostile that's in range and unobstructed line of sight, and shoot at it)
#
func configure_and_shoot(projectile_class: ProjectileManager.ProjectileClass, origin: Vector3, direction: Vector3, shooter: PhysicsBody3D) -> void: # TODO: WeaponTrigger.configure() needs to look up the projectile's settings, which may be a Dictionary or ProjectileDefinition created from a dictionary of parameters (c.f. Weapon)
	__projectile_class = projectile_class
	add_collision_exception_with(shooter)
	Global.add_to_level(self)
	global_position = origin
	# TODO: projectiles that have a solid form (grenade, rocket; any others?) will need to set their rotation as well so the 3D mesh points in correct direction; OTOH bullets have no visible shape and 2D billboard sprites are best for energy bolts; flamethrower will require some experimentation to find the right look (possibly a mixture of sphere meshes, materials, and sprites); however we only need bullets and energy bolts for Arrival Demo so can ignore 3D projectiles and flame for now
	__vector = direction * speed


func _physics_process(delta):
	var col = move_and_collide(__vector * delta)
	if col:
		
		# TODO: the detonation to play (if any) depends on what class of thing hits what other class of thing; therefore we need to look up the PROJECTILE_TRANSITION_DEFINITIONS table using collider and collidee types as keys; that will tell us the detonation to play, the damage to deal, and the visual animation to play; e.g.:
		#
		# - a bullet impacting an NPC will detonate producing a Player/Bob/Pfhor/Hulk/etc blood splash/armor spark and inflict detonation damage on that NPC
		#
		# - a bullet impacting a breakable window will detonate with an exploding glass effect, partially/fully destroying the window
		#
		# - a bullet impacting a wooden chair will detonate with wood chip effect, smashing the chair (assuming we implement breakable prop models as stretch goal; if not, it may knock it over)
		#
		# - a bullet impacting a metal wall will detonate with a riccochet sparek effect, with a random chance of leaving a black mark/dent on the wall
		#
		# - a bullet impacting water will detonate with a harmless water splash effect
		#
		# - and so on
		#
		# (In practice we might define bullet-into-liquid transitions as having a visual effect but no detonation, as detonations are really only needed when dealing damage to a collidee)
		#
		# Q. should Detonation
		
		
		var body = col.get_collider().get_parent() # TODO: what's easiest way to get the body's root node here, e.g. Player/NPC/Scenery/Wall/etc?
		print("Projectile hit: ", body.name)
		
		# temporary: TODO: the detonation class is dependent on the type of projectile and the type of thing it hits; eventually the appropriate detonation_class should be looked up based on TransitionDefinitions but for now we just duct-tape to a single "orange sphere" effect to show impacts
		var detonation_class = DetonationManager.detonation_class_for_type(Enums.DetonationType.PISTOL_BULLET_DETONATION)
		detonation_class.spawn(self.global_position, self, body)
		
		queue_free()
	

