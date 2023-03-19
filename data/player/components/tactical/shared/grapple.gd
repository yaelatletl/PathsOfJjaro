extends RigidBody3D

signal body_hit(point, body)
func _ready():
	connect("body_entered",Callable(self,"_on_body_entered"))
	pass

func _on_body_entered(_body):
	emit_signal("body_hit", global_transform.origin, _body)

