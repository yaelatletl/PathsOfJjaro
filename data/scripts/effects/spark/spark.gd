extends GPUParticles3D
@export var seconds : float = 0.1
func _ready() -> void:
	var timer = get_tree().create_timer(seconds)
	timer.connect("timeout",Callable(self,"queue_free"))
