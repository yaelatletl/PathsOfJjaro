extends Node3D



# TO DO: I think this is vaulting over railings; it is hard to tell. 

# In any case, Player vaulting (which is automatic behavior) needs a bit of thought on how best to trigger it. From Player/NPC POV, a railing may be non-solid; i.e. ledges retain their Classic structure, so anyone can run off the ledge at any time. (his will require a bit of work on incident angles: a very shallow angle would need to deflect the moving body along its basis to "throw" it over the railing quickly, otherwise it'll need a very slow-motion vault (very unconvincing); or it might prevent the body vaulting, keeping them on the ledge unless they turn into it. Also need to decide how best to detect Player/NPC colliding with railing; it's probably simpler for a static railing to detect the moving body entering its collision area and tell it to "vault".



@onready var actor = get_parent()
@onready var height_cast = $vault_over
@onready var forward_cast = $vault_over2
var movement = null

var on_ledge = false
var jump_over = false


func _ready():
	movement = actor._get_component("movement_basic")
	height_cast.add_exception(actor)
	forward_cast.add_exception(actor)



func _physics_process(delta):
	if height_cast.is_colliding() and not on_ledge:
		if height_cast.get_collider() is StaticBody3D and actor.run_speed < 12:
			on_ledge = true
	if on_ledge and actor.is_far_from_floor() and not forward_cast.is_colliding():
		actor.linear_velocity = -actor.wall_direction*2
		actor.linear_velocity.y += movement.gravity*delta
		if jump_over:
			actor.linear_velocity += (-actor.wall_direction + Vector3(0,1.5,0)) * 10
	else:
		rotation_degrees.y = actor.head.rotation_degrees.y
		jump_over = false
		on_ledge = false
	if actor.input["crouch"] and on_ledge:
		on_ledge = false
		actor.linear_velocity = actor.wall_direction*2
	elif actor.input["jump"] and on_ledge:
		actor.input["jump"] = 0
		jump_over = true

