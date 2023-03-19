extends Camera3D

@export var shake_time : float
@export var shake_force : float
@onready var actor = $"../../../"
func _ready() -> void:
	if get_tree().has_multiplayer_peer():
		if is_multiplayer_authority():
			make_current()

func _process(_delta : float) -> void:
	_shake(_delta)
	_tilt(_delta)
func _shake(_delta : float) -> void:
	if shake_time > 0:
		h_offset = randf_range(-shake_force, shake_force)
		v_offset = randf_range(-shake_force, shake_force)
		shake_time -= _delta
	else:
		h_offset = 0
		v_offset = 0

func _tilt(_delta : float) -> void:
	#wall_normal.normal is in global space, wall_normal is an object! 
	#camera forward/back is basis.z 

	#given a wall normal, tilt the camera to the opposite side of the wall
	if actor.wall_normal != null and actor.is_on_wall() and actor.linear_velocity.length() > 5 and actor.is_far_from_floor():
		var rotation_angle = global_transform.basis.z.cross(actor.wall_normal.normal*10).y

		if not is_zero_approx(rotation_angle):
			
			if rotation_angle < 0:
				rotation.z = lerp(rotation.z, 2, _delta)
			else:
				rotation.z  = lerp(rotation.z, -2, _delta)
	elif shake_time <= 0:
		rotation.z = lerp(rotation.z, 0, _delta) 

