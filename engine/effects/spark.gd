extends GPUParticles3D


# I assume `spark.tscn` = bullet strike animation, which is just another type of Explosion


@export var seconds : float = 0.1


func _ready() -> void:
	var timer = get_tree().create_timer(seconds) # TO DO: there's already an [unused] timer attached to the root node
	timer.connect("timeout",Callable(self,"queue_free")) # TO DO: this smells; either set the timer duration tto self.lifetime or to a sufficiently long fixed timeout (e.g. 10sec) it will never be exceeded
