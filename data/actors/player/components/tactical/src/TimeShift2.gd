extends Component

@export var camera_path: NodePath
@export var grapple_point: PackedScene
@export var throw_time: float = 0.2
@onready var camera : Camera3D = get_node(camera_path)



#Object dynamics and hook points
var static_collision_point = Vector3.ZERO
var non_static_collision_point = Vector3.ZERO

var grapple_is_activated : bool = false

func _screen_middle() -> Vector2:
	return get_tree().get_root().size/2

func _physics_process(delta):
	if enabled:
		_functional_routine(actor.input)
		
func _functional_routine(input : Dictionary) -> void:
	if get_key(input, "special"):
		_launch_teleporter()

func _launch_teleporter():
	var middle = camera.project_ray_normal(_screen_middle())
	var new_grap : RigidBody3D = grapple_point.instantiate()
	new_grap.connect("body_hit",Callable(self,"_on_body_entered").bind(new_grap))
	new_grap.set_as_top_level(true)
	new_grap.position = camera.global_transform.origin + 1.5*middle
	add_child(new_grap)
	new_grap.apply_central_impulse(4*middle)
	get_tree().create_timer(throw_time).connect("timeout",Callable(self,"_move_forward").bind(new_grap))


func _on_body_entered(_point : Vector3, _body : Node, grapple):
	if _body is Node3D:
		static_collision_point = _point
		if _body is RigidBody3D or _body is CharacterBody3D:
			non_static_collision_point = _body.to_local(_point)
		grapple_is_activated = true
		_move_forward(grapple)
		
		
func _move_forward(grapple):
	if is_instance_valid(grapple):
		actor.global_transform.origin = grapple.global_transform.origin + Vector3(0,1.5,0)
		grapple.queue_free()
