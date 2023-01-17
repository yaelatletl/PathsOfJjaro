extends RigidBody
class_name Projectile

var damage_type = Pooling.DAMAGE_TYPE.KINECTIC

export(float) var type : int = 0
export(float) var damage : int = 0
export(float) var speed : int = 100
export(float) var lifetime : float = 5.0

signal request_destroy()

func is_projectile(): # Helps avoid cyclic references
	return true 

func _init():
	connect("body_entered", self, "_on_body_entered")

func _ready():
	get_tree().create_timer(0.1).connect("timeout",  self, "_network_sync")

func add_exceptions(actor):
	add_collision_exception_with(actor)

func _network_sync() -> void:
	if is_inside_tree():
		Gamestate.set_in_all_clients(self, "translation", translation)
		get_tree().create_timer(0.1).connect("timeout",  self, "_network_sync")
	
func stop() -> void:
	sleeping = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	for exeptions in get_collision_exceptions():
		remove_collision_exception_with(exeptions)
	emit_signal("request_destroy")

func move(pos, dir) -> void:
	get_tree().create_timer(lifetime).connect("timeout", self, "stop")
	sleeping = false
	global_transform.origin = pos
	if is_inside_tree():
		linear_velocity = dir.normalized() * speed


func _on_body_entered(body) -> void:
	if body.has_method("is_projectile"):
		if body.type == type:
			return
	if body.has_method("_damage"):
		body._damage(damage, damage_type)
	stop()

