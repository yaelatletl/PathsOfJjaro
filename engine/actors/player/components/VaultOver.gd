extends Node3D


# TODO: This appears to be vaulting over railings, although its logic is not immediately clear and it overloads JUMP/CROUCH keys which is not good for consistent behavior. Leaving it here for reference only; delete it once vaulting is figured out and implemented in Player
#
# In any case, Player vaulting (which should be automatic behavior) needs a bit of thought on how best to trigger it. Our primary goal is that crouch, jump, and vault do not significantly change Classic gameplay. 
#
# For instance, the raised walkway in Arrival's pattern buffer room is high enough the Player cannot step up onto it; however, the new jump mechanic would allow the player to jump onto it. We can prevent jumping onto the walkway by placing a railing around it, which acts as an external barrier. When player is inside the barrier, however, they should still have the ability to run off the raised walkway to the lower floor area below. 
#
# To avoid affecting gameplay, the easiest solution may be to make the barrier non-solid when the player is level with it and running on solid ground (we'd also need to integrate airborne so that a jump or explosive impulse translates into a 'vault'). The Player would pass straight through the barrier as if it isn't there, replicating Classic's running-off-ledge movement. This can be supplemented with hand and camera animations and sound effect to create the illusion of the player jumping over a solid barrier. Vault will also need to check the angle of incidence, so approaching the railing at a very shallow angle either doesn't vault or else adds a lateral impulse to throw the player quickly sideways over it - we don't want the player's hands and camera animations to run out while player is still "on top of the railing"!
#
# Also need to decide how best to detect Player/NPC colliding with railing/close enough to vault it. Whereas jump should be fully automatic, using raycasts to determine jumpable rises, vault can use collision Areas as railings will always be separate assets placed on top of level geometry. It may be simplest for a StaticBody3D railing to detect a moving Player/NPC body entering its collision area, checking its speed and angle, and calling the object's `vault_railing` or `collided_with_railing` method, though it really depends if we want the Player to take off early (as in stair climbing) or wait till last moment (making contact) to perform its "vaulting" animation. 



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

