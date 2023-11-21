extends RayCast3D


# TO DO: why does this extend RayCast? seems like unnecessary complexity


@onready var actor = get_parent()
@onready var target = $neck/ViewTarget
@export var sensibility : float = 0.2  # Mouse sensitivitys



func _camera_rotation() -> void:
	# If the mouse is locked
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		

			# Rotates the camera checked the x axis

		rotation.x += -deg_to_rad(actor.input["look_y"] * sensibility)
			
			# Rotates the camera checked the y axis
		rotation.y += -deg_to_rad(actor.input["look_x"] * sensibility)

		
		# Creates a limit for the camera checked the x axis
		var max_angle: int = 85 # Maximum camera angle
		rotation.x = min(rotation.x,  deg_to_rad(max_angle))
		rotation.x = max(rotation.x, -deg_to_rad(max_angle))
		#await get_tree().create_timer(0.2).timeout
		#actor.input["look_y"] = 0
		#actor.input["look_x"] = 0

func _process(delta: float) -> void:
	# Calls the function to rotate the camera

	_camera_rotation()

