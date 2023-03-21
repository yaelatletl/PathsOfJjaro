extends Node

@onready var portals := [$PortalA, $PortalB]
@onready var links := {
	$PortalA: $PortalB,
	$PortalB: $PortalA,
}
var cameras = []
const epsilon = 0.01

@export var environment_path: NodePath = ""
@export_range(0.1, 2.0) var scale_factor = 1.0 
@export_range(0.1, 2.0) var render_scale = 1.0 
@onready var environment = get_node(environment_path)

# Dictionary between regular bodies and their clones
var clones := {}
@onready var bodies := {
	$PortalA: [],
	$PortalB: []
	}

func init_portal(portal: Node) -> void:
	# Connect the mesh material shader to the viewport of the linked portal
	var linked: Node = links[portal]
	var link_viewport: SubViewport = linked.get_node("SubViewport")
	var portal_camera: Camera3D = link_viewport.get_node("Camera3D")
	var tex := link_viewport.get_texture()
	var mat = portal.get_node("Screen").get_node("Back").material_override
	mat.set_shader_parameter("view_resolution",  get_viewport().size*render_scale)
	mat.set_shader_parameter("viewport", tex)
	if environment != null:
		portal_camera.environment = environment.environment
	cameras.append(portal_camera)
	var plane_normal = get_portal_plane(portal).normal
	print("The normal of the portal plane is: ", plane_normal)
	print("The normal of the portal is ", portal.transform.basis.z)
	sync_viewport(portal)
	


# Init portals
func _ready() -> void:
	for portal in portals:
		init_portal(portal)


func get_camera_3d() -> Camera3D:
	if Engine.is_editor_hint():
		return get_node("/root/EditorCameraProvider").get_camera_3d()
	else:
		return get_viewport().get_camera_3d()



func move_camera(portal: Node) -> void:
	var linked: Node = links[portal]
	var portal_direction = portal.global_transform.basis.z
	var linked_direction = linked.global_transform.basis.z
	var player_camera = get_camera_3d()
	var portal_camera = portal.get_node("SubViewport/Camera3D")
	var angle = portal_direction.angle_to(linked_direction)
	var camera_holder = portal.get_node("CameraHolder")
	if not portal_camera.is_inside_tree():
			return
	#var angle = PI - linked.global_rotation.y 
	var trans: Transform3D = linked.global_transform.inverse() * player_camera.global_transform
	trans = trans.rotated(Vector3.UP, angle)
	camera_holder.transform = trans
	#portal.get_node("CameraHolder").global_transform.origin += linked_direction.normalized() * 0.5
	var cam_pos: Transform3D = camera_holder.global_transform
	portal_camera.global_transform = cam_pos
	portal_camera.fov = player_camera.fov


# Sync the viewport size with the window size
func sync_viewport(portal: Node) -> void:
	#portal.get_node("SubViewport").size = get_viewport().size/4
	portal.get_node("SubViewport").size = set_viewport_size()

# warning-ignore:unused_argument
func _process(_delta: float) -> void:
	# TODO: figure out why this is needed
	if Engine.is_editor_hint():
		if get_camera_3d() == null:
			return
		_ready()
	for portal in portals:
		move_camera(portal)
		#sync_viewport(portal)

func set_viewport_size():
	var res_float = get_viewport().size * scale_factor
	#var native_aspect_ratio
	var viewport_size = Vector2(round(res_float.x), round(res_float.y))
	#var aspect_setting = get_aspect_setting()
	#if native_aspect_ratio and original_aspect_ratio and (aspect_setting != "ignore" and aspect_setting != "expand"):
	var aspect_diff = 1.0
	#if usage == USAGE_2D:
	#	if aspect_diff > 1.0 + epsilon and aspect_setting == "keep_width":
	#		viewport_size = Vector2(round(res_float.y * native_aspect_ratio), round(res_float.y))
	#	elif aspect_diff < 1.0 - epsilon and aspect_setting == "keep_height":
	#		viewport_size = Vector2(round(res_float.x), round(res_float.y / native_aspect_ratio))	
	#elif usage == USAGE_3D:
	if aspect_diff > 1.0 + epsilon:
		viewport_size = Vector2(round(res_float.x / aspect_diff), round(res_float.y))
	elif aspect_diff < 1.0 - epsilon:
		viewport_size = Vector2(round(res_float.x), round(res_float.y * aspect_diff))
	return viewport_size

# Return whether the position is in front of a portal
func in_front_of_portal(portal: Node3D, pos: Transform3D) -> bool:
	var portal_pos = portal.global_transform.basis
	var distance = pos.origin.dot(portal_pos.z)
	var further_from_portal = distance < 0.0
	#var approximately_in_front = is_zero_approx(distance)
	#var approximately_in_front = distance > 0
	var approximately_in_front = get_portal_plane(portal).is_point_over(pos.origin) and not is_zero_approx(distance)
	return further_from_portal and not approximately_in_front

#Swapping is inconsistent with relative positions
# Swap the velocities and positions of a body and its clone
func swap_body_clone(body: PhysicsBody3D, clone: PhysicsBody3D, angle : float, linked_z_basis : Vector3) -> void:
	var body_vel: Vector3 = Vector3.ZERO
	var clone_vel: Vector3 =  Vector3.ZERO
	var body_pos := body.global_transform
	var clone_pos := clone.global_transform
	if body is CharacterBody3D and body.has_method("_get_component"):
		body.get_node("weapons").global_transform.basis = get_camera_3d().global_transform.basis
#		body.linear_velocity = body.linear_velocity.rotated(Vector3.UP, angle) 
		#body.global_transform.basis.rotated(Vector3.UP, angle)
	clone.global_transform = body_pos
	body.global_transform = clone_pos 

	if clone is CharacterBody3D:
		clone_vel = clone.get_meta("linear_velocity")
	elif clone is RigidBody3D:
		clone_vel = clone.linear_velocity
	if (body.has_method("_get_component") and body is CharacterBody3D) or body is RigidBody3D:
		#print("Initial velocity of body: ", body.linear_velocity, " rotation: ", body.global_rotation)
		body_vel = body.linear_velocity

	if body is RigidBody3D:
		body.sleeping = true
		clone.sleeping = true
	#Swap the velocities
	

	if clone is CharacterBody3D:
		clone.set_meta("linear_velocity", body_vel)
	elif clone is RigidBody3D:
		clone.linear_velocity = body_vel


	#body.global_transform.origin -= linked_z_basis.normalized() * 0.00001
	if (body.has_method("_get_component") and body is CharacterBody3D) or body is RigidBody3D:
		body.linear_velocity = clone_vel
#		print("Velocity of body after no swap: ", body.linear_velocity, " rotation: ", body.global_rotation)
	#print("Position of body after swap: ", body.global_transform.origin, " rotation: ", body.global_rotation)

func clone_duplicate_material(clone: PhysicsBody3D) -> void:
	for child in clone.get_children():
		if child.has_method("get_surface_override_material"):
			# TODO: iterate over materials
			var material: Material = child.get_surface_override_material(0)
			material = material.duplicate(false)
			child.set_surface_override_material(0, material)


func handle_clones(portal: Node, body: PhysicsBody3D) -> void:
	if body is StaticBody3D:
		return
	var linked: Node = links[portal]

	var body_pos := body.global_transform
	var portal_pos = portal.global_transform
	var linked_pos = linked.global_transform
	var portal_direction = portal_pos.basis.z
	var linked_direction = linked_pos.basis.z
	#var angle = PI - portal_direction.angle_to(linked_direction)
	var angle = portal_direction.angle_to(linked_direction)
	#var angle = PI - linked.global_rotation.y 
	
	#var angle =  portal.global_rotration.y linked.global_rotation.y 	

	# Position of body relative to portal
	var rel_pos = portal.to_local(body_pos.origin) * Vector3(-1, 1, -1)
	var rel_rot = body_pos.basis.rotated(Vector3.UP, PI-angle)
	var clone: PhysicsBody3D
	
	if body in clones.keys():
		clone = clones[body]
	elif body in clones.values():
		return	
	else:
		if body is RigidBody3D:
			clone = body.duplicate(1)
		elif body is CharacterBody3D:
			clone = Pooling.duplicate_actor(body)
		if clone is CharacterBody3D:
			clone.get_node("ThirdPersonModel").visible = false
			clone.collision_layer = 0
			clone.collision_mask = 0
			
		clones[body] = clone
		add_child(clone)
	if clone is RigidBody3D:
		clone.linear_velocity = body.linear_velocity.rotated(Vector3.UP, PI-angle) 
	elif clone is CharacterBody3D and body.has_method("_get_component"):
		clone.set_meta("linear_velocity", body.linear_velocity.rotated(Vector3.UP, PI-angle))
	clone_duplicate_material(clone)
	
	clone.global_transform.origin = linked.to_global(rel_pos)
	clone.global_transform.basis = rel_rot
	
	# Swap clone and actual if the actual object is more than halfway through 
	# the portal
	if not in_front_of_portal(portal, body_pos):
		swap_body_clone(body, clone, angle, linked_direction)
		handle_body_exit_portal(portal, body)
	
	


func get_portal_plane(portal: Node3D) -> Plane:
	#var global_portal_plane = Plane(portal.to_global(Vector3(0, 0, 1)), 0)
	#return portal.global_transform * global_portal_plane
	# Fix rotation first

	return portal.global_transform * Plane.PLANE_XY


func portal_plane_rel_body(portal: Node3D, body: PhysicsBody3D) -> Color:
	var global_plane := get_portal_plane(portal)
	var plane: Plane = body.global_transform.inverse() * global_plane
	return Color(-plane.x, -plane.y, -plane.z, -plane.d)


func add_clip_plane(portal: Node3D, body: PhysicsBody3D) -> void:
	if body is StaticBody3D:
		return
	var plane_pos := portal_plane_rel_body(portal, body)
	for body_child in body.get_children():
		if body_child.has_method("get_surface_override_material"):
			# TODO: iterate over materials
			var material = body_child.get_surface_override_material(0)
			if material.has_method("set_shader_parameter"):
				material.set_shader_parameter("portal_plane", plane_pos)


func handle_body_overlap_portal(portal: Node3D, body: PhysicsBody3D) -> void:
	handle_clones(portal, body) # 45 ms for 1 CharacterBody3D, yikes
	add_clip_plane(portal, body) #This is O(n)


# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	# Don't handle physics while in the editor
	if Engine.is_editor_hint():
		return

	# Check for bodies overlapping portals
	for portal in portals:
		for body in bodies[portal]: #O(n^2)
			handle_body_overlap_portal(portal, body)

func handle_body_exit_portal(portal: Node, body: PhysicsBody3D) -> void:
	if not is_instance_valid(body):
		return
	if not body in clones:
		return
	var clone: Node = clones[body]
	if is_instance_valid(clone):
		clones.erase(body)
		if clone is RigidBody3D:
			clone.queue_free()
		elif clone is CharacterBody3D:
			Pooling.free_actor_duplicate(clone)
	bodies[portal].erase(body)

func _on_portal_a_body_entered(body: PhysicsBody3D) -> void:
	bodies[$PortalA].append(body)

func _on_portal_b_body_entered(body: PhysicsBody3D) -> void:
	bodies[$PortalB].append(body)

func _on_portal_a_body_exited(body: PhysicsBody3D) -> void:
	handle_body_exit_portal($PortalA, body)
	bodies[$PortalA].erase(body)

func _on_portal_b_body_exited(body: PhysicsBody3D) -> void:
	handle_body_exit_portal($PortalB, body)
	bodies[$PortalB].erase(body)
