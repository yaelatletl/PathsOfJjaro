extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func _process(delta):
 translation = get_node("../CameraCollision").translation
