extends Node3D

@export var timer: NodePath

func _ready() -> void:
	timer = get_node(timer)
	
	timer.connect("timeout",Callable(self,"queue_free"))
