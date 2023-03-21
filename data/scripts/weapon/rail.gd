extends Node3D

var speed : float = 200
@export var seconds: float = 0.1

func _ready() -> void:
	$mesh.position.z = -$mesh.mesh.height/2
	var timer = get_tree().create_timer(seconds)
	timer.connect("timeout",Callable(self,"queue_free"))

func _process(_delta) -> void:
	global_transform.origin -= (global_transform.basis.z * speed) * _delta
