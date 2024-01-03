extends Node


# engine/projectile/ProjectileManager.gd -- manages projectile classes corresponding to each ProjectileType


# important: global Managers must be Autoloaded in order of dependency, e.g. WeaponManager requires InventoryManager and ProjectileManager to initialize itself so those MUST be autoloaded before it; see Project Settings > Autoload for load order


var __projectile_classes := {}



func _ready() -> void:
	#print("ProjectileManager initialize")
	for definition in ProjectileDefinitions.PROJECTILE_DEFINITIONS:
		var projectile_class = ProjectileClass.new()
		projectile_class.configure(definition)
		__projectile_classes[definition.projectile_type] = projectile_class
		#print("Added ProjectileClass for type ", definition.projectile_type)



func projectile_class_for_type(projectile_type: Enums.ProjectileType) -> ProjectileClass:
	assert(projectile_type in __projectile_classes, "Unrecognized projectile_type: %s" % projectile_type)
	var projectile_class = __projectile_classes[projectile_type]
	return projectile_class






class ProjectileClass extends Object: # note: about memory management for this and other physics definition classes: these are instantiated when a scenario loads and will persist until/unless it is unloaded, so are implemented as single-owner (no need for RefCounted overheads); if/when scenario unloading is implemented, Managers will eventually need to explicitly free these objects before creating new ones, but that need is well in the future so don't worry about free-ing for now

	# TODO: this holds all information relating to a specific ProjectileType; projectiles are relatively simple so shouldn't need type-specific Projectile subclasses, although we might define a HomingProjectile subclass as that does have extra behavior which is easier iimplemented as subclass than bool flag
	
	const Projectile := preload("Projectile.tscn")
	
	var projectile_type: Enums.ProjectileType
	
	
	func configure(definition: Dictionary) -> void:
		projectile_type = definition.projectile_type
		# TODO: this can do a partial lookup of transition table, getting all the from-into transitions that apply to this projectile type; that cuts down the amount of work that needs to be done when spawning the projectile and detonating it


	func spawn(origin: Vector3, direction: Vector3, shooter: PhysicsBody3D) -> void:
		# TODO: we will eventually need to check the media at origin point (the shooter's global position within the map), as e.g. firing fusion under liquid produces an immediate detonation; whether we check this here and skip the Projectile creation and destruction (since it travels 0m before exploding) or if we create the projectile anyway (which is probably cheap enough to do) and let it perform the Detonation is TBD
		Projectile.instantiate().configure_and_shoot(self, origin, direction, shooter)


