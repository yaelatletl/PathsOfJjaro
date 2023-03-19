extends Node3D


@export var movement_path: NodePath
@onready var character = get_parent()
@onready var height_cast = $vault_over
@onready var forward_cast = $vault_over2
@onready var movement = get_node(movement_path)

var on_ledge = false
var jump_over = false


func _ready():
	height_cast.add_exception(character)
	forward_cast.add_exception(character)



func _physics_process(delta):
	if height_cast.is_colliding() and not on_ledge:
		if height_cast.get_collider() is StaticBody3D and character.run_speed < 12:
			on_ledge = true
	if on_ledge and character.is_far_from_floor() and not forward_cast.is_colliding():
		character.linear_velocity = -character.wall_direction*2
		character.linear_velocity.y += movement.gravity*delta
		if jump_over:
			character.linear_velocity += (-character.wall_direction + Vector3(0,1.5,0)) * 10
	else:
		rotation_degrees.y = character.head.rotation_degrees.y
		jump_over = false
		on_ledge = false
	if character.input["crouch"] and on_ledge:
		on_ledge = false
		character.linear_velocity = character.wall_direction*2
	elif character.input["jump"] and on_ledge:
		character.input["jump"] = 0
		jump_over = true

