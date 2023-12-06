extends Area3D
class_name PlatformPressureHandler


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	var elevator = get_parent().get_parent()
	elevator.active = true
