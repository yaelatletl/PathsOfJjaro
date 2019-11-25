# This script determines the behaviour of the fusion bolt (not supercharge)
extends RigidBody
var explosion = preload("res://Joyeuse/Basics/Guns/explosion.tscn")
var sound = "res://assets/sounds/M1/MA75B_explosion.wav"
var damage = 90
var radius = 2.5
# variables for position and speed
var pos
export var speed = 10
var wielder

func setup(wieldee):
	wielder = wieldee

func _ready():
	# set transform relative to global
	set_as_toplevel(true)
	# get current position/orientation
	pos = get_transform()
	# determine basis for flight
	var dir = get_global_transform().basis*Vector3(0,0,-1).normalized()
	# exert impulse on bolt to propel it.
	apply_impulse(Vector3(),dir * speed )
	
func _physics_process(delta):
	if $RayCast.is_colliding() or $RayCast2.is_colliding() or $RayCast3.is_colliding():
		collision(null)

func calculate_falloff(veca, vecb):
	var direction = vecb-veca
	var distance = direction.length()
	var force = radius-distance
#	if force > 0:
	return -(damage)*direction.normalized()/distance
#	else:
#		return Vector3()
func explode():
	get_parent().add_child(AutoSound3D.new(sound, translation))
	for bodies in$Area.get_overlapping_bodies():
		if bodies.has_method("hit"):
			bodies.hit(damage)
		if bodies.has_method("apply_impulse"):
			bodies.apply_impulse(Vector3(), calculate_falloff(bodies.to_global(bodies.translation),to_global(translation)))
	var splode = explosion.instance()
	splode.set_as_toplevel(true)
	splode.set_global_transform(get_global_transform())
	get_parent().add_child(splode)

func collision( body = null):
	# if its a character or object (wall, etc)
	# so long as the object is NOT the bolt itself (since the bolt is a rigid body)
	if body == wielder:
		return
	explode()
	queue_free()

func _on_Area_body_entered(body):
	collision(body)
