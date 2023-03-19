extends Component

remotesync var on_the_net_transform : Vector3 = Vector3()
remotesync var on_the_net_velocity : Vector3 = Vector3()
remotesync var on_the_net_camera_look : Vector3 = Vector3()
remotesync var on_the_net_height : float = 2.0
puppet var local_net_transform : Vector3 = Vector3()
puppet var local_net_velocity : Vector3 = Vector3()
puppet var local_net_camera_look : Vector3 = Vector3()
puppet var local_net_height : float = 2.0
@export var head_path: NodePath
@export var sync_delta: float : float = 1
@export var sync_delta_angle: float : float = 15
@onready var head = get_node(head_path)
@onready var shape = actor.get_node("collision")
var average_true_transform : Vector3 = 	Vector3()
var average_true_velocity : Vector3 = Vector3()
var average_true_view : Vector3 = Vector3()
var average_true_height : float

func _ready() -> void:
	on_the_net_camera_look = head.rotation
	local_net_transform = head.rotation

func update_server_from_client():
	#We update here where the player thinks they are. 
	rset_unreliable_id(1, "local_net_transform", actor.global_transform.origin)
	rset_unreliable_id(1, "local_net_height", shape.shape.height)
	rset_unreliable_id(1, "local_net_camera_look", actor.head.rotation)
	rset_unreliable_id(1, "local_net_velocity", actor.linear_velocity)
			
func update_client_from_server():
	#We send the real position (as where the player actually is for the server)
	if get_tree().is_server():
		Gamestate.unreliable_set_in_all_clients(self, "on_the_net_transform", average_true_transform )
		Gamestate.unreliable_set_in_all_clients(self, "on_the_net_height", average_true_height)
		Gamestate.unreliable_set_in_all_clients(self, "on_the_net_camera_look", average_true_view)
		Gamestate.unreliable_set_in_all_clients(self, "on_the_net_velocity", actor.linear_velocity)

func interpolate_reality_to_expectation(delta):
	if get_tree().is_server():
		var transform_delta = actor.global_transform.origin.distance_to(local_net_transform)
		var height_distance = abs(shape.shape.height - local_net_height)
		var velocity_delta = actor.linear_velocity.distance_to(local_net_velocity)
		if  transform_delta < sync_delta:
			average_true_transform = lerp(actor.global_transform.origin, local_net_transform, delta*transform_delta)
		else:
			average_true_transform = actor.global_transform.origin
		if  height_distance > 0.2 and local_net_height <= 2:
			average_true_height = lerp(shape.shape.height, local_net_height, delta*height_distance)
		else:
			average_true_height = shape.shape.height
		if  velocity_delta < sync_delta:
			average_true_velocity = lerp(actor.linear_velocity, local_net_velocity, delta*velocity_delta)
		else:
			average_true_velocity = actor.linear_velocity
			

func sync_from_server(delta):
	if on_the_net_transform == null or local_net_transform == null:
		return
	if not get_tree().is_server():
		
		if actor.global_transform.origin.distance_to(on_the_net_transform) < sync_delta * 2:
			
			actor.global_transform.origin.lerp(on_the_net_transform, delta)
		else:
			actor.global_transform.origin = on_the_net_transform
		if abs(shape.shape.height - on_the_net_height) > 0.2 and on_the_net_height <= 2:
			shape.shape.height = lerp(shape.shape.height, on_the_net_height, delta)
		else:
			shape.shape.height = on_the_net_height
		if actor.linear_velocity.distance_to(on_the_net_velocity) < sync_delta:
			actor.linear_velocity.lerp(on_the_net_velocity, delta)
		else:
			actor.linear_velocity = on_the_net_velocity

func sync_rotation(delta : float) -> void:
	if local_net_camera_look == null or on_the_net_camera_look == null:
		return	
	if get_tree().is_server():
		if local_net_camera_look != null and get_multiplayer_authority() != 1:
			head.rotation =  local_net_camera_look
	elif not is_multiplayer_authority():
		var distance_factor = head.rotation.angle_to(on_the_net_camera_look)
		if distance_factor != null:
			head.rotation = lerp_angles(head.rotation, on_the_net_camera_look, rad_to_deg(abs(distance_factor))*delta+delta)
	#if get_tree().is_server():
	#	if get_tree().get_unique_id() != get_multiplayer_authority():
	#		actor.head.rotation = local_net_camera_look 
		# if actor.head.rotation.angle_to(local_net_camera_look) < deg_to_rad(sync_delta_angle):
		# 	average_true_view =local_net_camera_look  #lerp_angles(actor.head.rotation, local_net_camera_look, delta)
		# else:
		# 	average_true_view = actor.head.rotation
	
	# if not get_tree().is_server():
	# 	if actor.head.rotation.angle_to(on_the_net_camera_look) < deg_to_rad(sync_delta_angle):
	# 		actor.head.rotation = lerp_angles(actor.head.rotation, on_the_net_camera_look, delta)
	# 	else:
	# 		actor.head.rotation = on_the_net_camera_look


func _physics_process(delta: float) -> void:
	if not enabled:
		return
	if get_tree().is_server():
		interpolate_reality_to_expectation(delta*100)
		update_client_from_server()
	else:
		if is_multiplayer_authority():
			update_server_from_client()
		sync_from_server(delta*10)



			
func _process(delta: float) -> void:
	if not enabled:
		return

	sync_rotation(delta*10)


func lerp_angles(rotation_from : Vector3, rotation_to : Vector3, delta: float) -> Vector3:
	return Vector3(
		lerp_angle(rotation_from.x, rotation_to.x, delta),
		lerp_angle(rotation_from.y, rotation_to.y, delta),
		lerp_angle(rotation_from.z, rotation_to.z, delta)
		)
		
func lerp_transform(local_transform : Transform3D, network_transform : Transform3D, delta : float) -> Transform3D:
	var quat_local = local_transform.basis.get_rotation_quaternion()
	var quat_network = network_transform.basis.get_rotation_quaternion()
	return Transform3D(Basis(quat_local.slerp(quat_network, delta).normalized()), local_transform.origin.slerp(network_transform.origin,delta))
