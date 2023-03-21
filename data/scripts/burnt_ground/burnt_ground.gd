extends Node3D

@export var ray: NodePath
@onready var ray_node = get_node(ray)
var ground : bool = false

func _process(delta):
	if not ground:
		if ray_node.is_colliding():
			$mesh.global_transform.origin = ray_node.get_collision_point() + Vector3(0, 0.1, 0)
			ground = false
