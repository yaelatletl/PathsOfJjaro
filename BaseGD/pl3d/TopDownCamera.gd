extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func _process(delta):
	rotation_degrees.x = clamp(rotation_degrees.x,-90,-90)
	rotation_degrees.y = clamp(rotation_degrees.y,0,0)
	rotation_degrees.z = clamp(rotation_degrees.z,0,0)
