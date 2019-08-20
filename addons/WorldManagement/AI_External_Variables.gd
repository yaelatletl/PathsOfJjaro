extends KinematicBody
var grav = 0.0
var gravity = Vector3()
var health = 0
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	print("Initialized AI Succesfully")
	set_process(true)
	pass

func _process(delta):
	$AI.gravity = gravity
	health = $AI.health
	