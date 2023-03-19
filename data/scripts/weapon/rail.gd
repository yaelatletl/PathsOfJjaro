extends Node3D

var speed : float = 200
@export var timer: NodePath

func _ready() -> void:
	$mesh.position.z = -$mesh.mesh.height/2
	timer = get_node(timer)
	timer.connect("timeout",Callable(self,"queue_free"))

func _process(_delta) -> void:
	global_transform.origin -= (global_transform.basis.z * speed) * _delta
