extends Spatial

onready var actor = get_parent()
onready var view_target = $ViewTarget

export(float) var rotation_offset = 90
export(float) var sharp_rotation_angle = 45

var previous_rotation = deg2rad(rotation_offset)
var target_rotation = 0

func _ready() -> void:
	actor.connect("died", self, "die")
func angle_difference(x, y):
	return abs(min((2 * PI) - abs(x - y), abs(x - y)))



func _process(delta: float) -> void:
	if is_instance_valid(actor.head):
		if angle_difference(rotation.y, actor.head.rotation.y + deg2rad(rotation_offset)) > deg2rad(sharp_rotation_angle):
			target_rotation = actor.head.rotation.y + deg2rad(rotation_offset)
		if angle_difference(rotation.y, target_rotation) > deg2rad(sharp_rotation_angle/2):
			rotation.y = lerp_angle(rotation.y, target_rotation, 2*delta)

				
func _physics_process(delta: float) -> void:
	if is_instance_valid(actor.head.target):
		view_target.global_transform = actor.head.target.global_transform

func die():
	$ViewTarget/IK_LookAt.update_mode = 3
	$RootNode/Skeleton.physical_bones_start_simulation()
