extends Node3D

@export var seconds: float

func _ready() -> void:
	var timer = get_tree().create_timer(seconds)
	timer.connect("timeout",Callable(self,"queue_free"))
