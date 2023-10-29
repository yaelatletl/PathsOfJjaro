extends Component

remotesync var on_the_net_transform : Vector3 = Vector3()
remotesync var on_the_net_camera_look : Vector3 = Vector3()
remotesync var on_the_net_height : float = 2.0
remotesync var on_the_net_velocity : Vector3 = Vector3()
remotesync var local_camera_look : Vector3 = Vector3()

@export var head_path: NodePath
@onready var head = get_node(head_path)
@onready var shape = actor.get_node("collision")

func _physics_process(delta: float) -> void:
	if not get_tree().has_multiplayer_peer():
		return
	
	if get_tree().is_server():
		rset_unreliable("on_the_net_transform", actor.global_transform.origin)
		rset_unreliable("on_the_net_camera_look", head.rotation)
		rset_unreliable("on_the_net_height", shape.shape.height)
		rset_unreliable("on_the_net_velocity", actor.linear_velocity)
	else:
		actor.global_transform.origin = lerp(actor.global_transform.origin, 
			on_the_net_transform, 
			clamp(delta*actor.global_transform.origin.distance_to(on_the_net_transform), delta, 1.0)
		)

		shape.shape.height = lerp(shape.shape.height, 
			on_the_net_height, 
			clamp(abs(shape.shape.height-on_the_net_height)*delta, delta, 1.0)
		)

		actor.linear_velocity = lerp(actor.linear_velocity, 
			on_the_net_velocity, 
			clamp(delta*actor.linear_velocity.distance_to(on_the_net_velocity), delta, 1.0)
		)
	if mpAPI.is_server():
		rset_unreliable_id(1, "local_camera_look", head.rotation)
		
func _process(delta: float) -> void:
	if not get_tree().has_multiplayer_peer():
		return
	if get_tree().is_server():
		if local_camera_look != null and get_multiplayer_authority() != 1:
			head.rotation =  local_camera_look
	elif not mpAPI.is_server():
		var distance_factor = head.rotation.angle_to(on_the_net_camera_look)
		if distance_factor != null:
			head.rotation = lerp_angles(head.rotation, on_the_net_camera_look, rad_to_deg(abs(distance_factor))*delta+delta)
		

		
func lerp_angles(rotation_from : Vector3, rotation_to : Vector3, delta: float) -> Vector3:
	return Vector3(
		lerp_angle(rotation_from.x, rotation_to.x, delta),
		lerp_angle(rotation_from.y, rotation_to.y, delta),
		lerp_angle(rotation_from.z, rotation_to.z, delta)
		)
