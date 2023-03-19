extends Node3D

@onready var actor = get_parent()
@onready var view_target = $ViewTarget

@export var rotation_offset: float: float = 90
@export var sharp_rotation_angle: float: float = 45

var previous_rotation : float = deg_to_rad(rotation_offset)
var target_rotation : float = 0
var model_meshes : Array = []

@onready var teleport_shader = MaterialPool.teleport

var teleporting = false
var teleporting_in = false

func find_meshes(node : Node) -> void:
	if node is MeshInstance3D:
		model_meshes.append(node)
	for child in node.get_children():
		find_meshes(child)


func _ready() -> void:
	find_meshes(self)
	actor.connect("died",Callable(self,"die"))
	scale= Vector3(0.01, 1, 0.01)
	get_tree().create_timer(3).connect("timeout",Callable(self,"teleport_in"))
	get_tree().create_timer(10).connect("timeout",Callable(self,"teleport_out"))



func angle_difference(x : float, y : float) -> float:
	return abs(min((2 * PI) - abs(x - y), abs(x - y)))

func teleport_in() -> void:
	if get_node_or_null("SFX"):
		get_node("SFX").play()
	if teleporting:
		return
	teleporting = true
	teleporting_in = true

func teleport_out() -> void:
	if teleporting:
		return
	teleporting = true
	teleporting_in = false

func teleport_out_effect(delta : float) -> void:
	# lerp x and z scale from 1 to 0
	# override material to teleport material
	if teleporting_in or not teleporting:
		return
	scale.x = lerp(scale.x, 0.01, 10*delta)
	scale.z = lerp(scale.z, 0.01, 10*delta)
	if scale.x > 0.01:
		for mesh in model_meshes:
			if mesh.get_surface_override_material(0) != teleport_shader:
				mesh.set_surface_override_material(0, teleport_shader)
	if scale.x < 0.01:
		for mesh in model_meshes:
			if mesh.get_surface_override_material(0) == teleport_shader:
				mesh.set_surface_override_material(0, null)
		teleporting = false

func teleport_in_effect(delta : float) -> void:
	# lerp x and z scale from 0 to 1
	# override material to teleport material
	if not teleporting_in:
		return
	scale.x = lerp(scale.x, 1, 10*delta)
	scale.z = lerp(scale.z, 1, 10*delta)
	if scale.x < 0.99:
		for mesh in model_meshes:
			if mesh.get_surface_override_material(0) != teleport_shader:
				mesh.set_surface_override_material(0, teleport_shader) 
	if scale.x > 0.99:
		for mesh in model_meshes:
			if mesh.get_surface_override_material(0) == teleport_shader:
				mesh.set_surface_override_material(0, null)
		teleporting = false
		teleporting_in = false
	


func _process(delta: float) -> void:
	teleport_out_effect(delta)
	teleport_in_effect(delta)
	if is_instance_valid(actor.head) and not teleporting:
		if angle_difference(rotation.y, actor.head.rotation.y + deg_to_rad(rotation_offset)) > deg_to_rad(sharp_rotation_angle):
			target_rotation = actor.head.rotation.y + deg_to_rad(rotation_offset)
		if angle_difference(rotation.y, target_rotation) > deg_to_rad(sharp_rotation_angle/2):
			rotation.y = lerp_angle(rotation.y, target_rotation, 2*delta)

				
func _physics_process(delta: float) -> void:
	if teleporting:
		$ViewTarget/IK_LookAt.update_mode = 3
	else:
		$ViewTarget/IK_LookAt.update_mode = 0

	if is_instance_valid(actor.head) and not teleporting:
		if is_instance_valid(actor.head.target):
			view_target.global_transform = actor.head.target.global_transform

func die() -> void:
	$ViewTarget/IK_LookAt.update_mode = 3
	$RootNode/Skeleton3D.physical_bones_start_simulation()
