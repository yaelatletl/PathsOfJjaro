extends RigidBody3D # TO DO: StaticBody3D is probably sufficient for projectiles as other bodies cannot affect a projectile's movement, only trigger its explosion
class_name Projectile

# Projectile.gd


# TO DO: sort out this implementation; don't use Pooling for now (caching can be added once engine is functionally complete if performance profiling shows new/free calls are a bottleneck, but right now it just complicates the code and slows development)


var damage_type = Pooling.DAMAGE_TYPE.KINECTIC # define a Constants.DamageType

@export var type : int = 0
@export var damage : int = 0
@export var speed  : int = 100
@export var lifetime : float = 5.0

signal request_destroy() # this should be unnecessary

func is_projectile(): # Helps avoid cyclic references # this should be unnecessary
	return true 



func _init():
	connect("body_entered",Callable(self,"_on_body_entered"))

func _ready():
	pass

func add_exceptions(actor):
	add_collision_exception_with(actor) # TO DO: a projectile needs an exception for the Player/Enemy that fired it


	
func configure_and_shoot(): # TO DO: what to pass here? it needs access to the level's scene tree (so that the projectile's life is scoped to that level; when the player exits a level, the level and all extant NPCS, items, explosions, projectiles, etc freed too), it also needs to know its point of origin and direction (both provided by the Player/NPC in the initial 'shoot' call), and projectile_type (so it nows what asset to use and what its speed, gravitation, explosion_type, etc are); it also needs an owner (the Player or NPC that fired it) so its collision exception can be set
	pass
#	offset = Vector3(offset.x, offset.y, 0)
#	var direction = camera.to_global(Vector3.ZERO) - camera.to_global(Vector3(0,0,100) + offset)
	# Add the projectile to the scene through pooling
	
	# add_collision_exception_with(owner)
	
#	Pooling.add_projectile(projectile_type, origin, direction, actor) # get rid of this


#
func stop() -> void:
	sleeping = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	for exeptions in get_collision_exceptions(): # needed? it's redundant if the projectile is discarded
		remove_collision_exception_with(exeptions)
	#emit_signal("request_destroy")


func move(pos, dir) -> void:
	get_tree().create_timer(lifetime).connect("timeout",Callable(self,"stop"))
	sleeping = false
	global_transform.origin = pos
	if is_inside_tree():
		linear_velocity = dir.normalized() * speed


func _on_body_entered(body) -> void:
	#if body.has_method("is_projectile"):
	#	if body.type == type:
	#		return
	#if body.has_method("_damage"): # TO DO: 
	#body._damage(damage, damage_type)
	stop() # TO DO: this needs more work: some bodies (walls, player, enemies, some scenery objects) will stop the projectile and trigger its explosion while other bodies may be destroyed by the projectile while allowing some projectile types to pass through; e.g. a glass bottle won't stop a bullet or (which continues until it hits something bigger) but it will [presumably] stop a grenade (which explodes on any contact) (alien projectiles such as Pfhor staff, both melee and ranged, and Compiler energy blasts will presumably continue through the bottle too); one option is to define SoftCollision vs HardCollision as subclasses of CollisionShape3D and use those as collision shapes on all solids; those classes can implement different behaviors for destroy-and-pass-thru vs stop-and-explode and handle the initial _on_body_entered signal

