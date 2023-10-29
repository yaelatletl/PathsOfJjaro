extends Node3D

@onready var actor = get_parent()
@onready var view_target = $ViewTarget

@export var rotation_offset: float = 90
@export var sharp_rotation_angle: float = 45

var previous_rotation = deg_to_rad(rotation_offset)
var target_rotation = 0

func _ready() -> void:
	actor.connect("died",Callable(self,"die"))
func angle_difference(x, y):
	return abs(min((2 * PI) - abs(x - y), abs(x - y)))



func _process(delta: float) -> void:
	if is_instance_valid(actor.head):
		if angle_difference(rotation.y, actor.head.rotation.y + deg_to_rad(rotation_offset)) > deg_to_rad(sharp_rotation_angle):
			target_rotation = actor.head.rotation.y + deg_to_rad(rotation_offset)
		if angle_difference(rotation.y, target_rotation) > deg_to_rad(sharp_rotation_angle/2):
			rotation.y = lerp_angle(rotation.y, target_rotation, 2*delta)

				
func _physics_process(delta: float) -> void:
	if actor.head == null:
		return
	if is_instance_valid(actor.head.target):
		view_target.global_transform = actor.head.target.global_transform

func die():
	$ViewTarget/IK_LookAt.update_mode = 3
	$RootNode/Skeleton3D.physical_bones_start_simulation()
