# This script determines the behaviour of the fusion bolt (not supercharge)

extends Projectile

# variables for position and speed
var sound = "res://assets/sounds/M1/Fusion_Pistol_hit.wav"

func setup(wieldee):
	wielder = wieldee

func _ready():
	get_parent().emit_signal("sound_emitted", translation, 1)
	speed = 25
	# set transform relative to global
	set_as_toplevel(true)
	
	# get current position/orientation
	pos = get_transform()
	
	# determine basis for flight
	var dir = get_global_transform().basis*Vector3(0,0,-1).normalized()
	
	# exert impulse on bolt to propel it.
	set_linear_velocity(dir * speed)
	apply_impulse(Vector3(),dir * speed ) 
	

# when the hitbox collides with something:
func collision( body = null):
	
	# if its a character or object (wall, etc)
	# so long as the object is NOT the bolt itself (since the bolt is a rigid body)
	if body == wielder:
		return
	if body == null:
		pass
	elif body.has_method("hit"):
		body.hit(damage)
		
		
	get_parent().add_child(AutoSound3D.new(sound, translation))
	queue_free()
	
func _on_Area_body_entered(body):
	collision(body)
		
func _physics_process(delta):
	if $RayCast.is_colliding() or $RayCast2.is_colliding() or $RayCast3.is_colliding():
		collision(null)
	

