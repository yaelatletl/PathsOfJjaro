extends Projectile

var bodies_to_explode : Array = []

export(float) var impulse = 10

func explode() -> void:
	for body in bodies_to_explode:
		if body is RigidBody:
			body.apply_central_impulse((body.global_transform.origin - global_transform.origin).normalized() * impulse)
		elif body is KinematicBody:
			if body.has_method("_get_component"):
				body._get_component("movement_basic").add_impulse((body.global_transform.origin - global_transform.origin).normalized() * impulse)
		body._damage(damage, Pooling.DAMAGE_TYPE.EXPLOSIVE)

func stop() -> void:
	sleeping = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	explode()
	for exeptions in get_collision_exceptions():
		remove_collision_exception_with(exeptions)
	emit_signal("request_destroy")

func _on_Area_body_entered(body) -> void:
	if body.has_method("is_projectile"):
		if body.type == type:
			return
	if body.has_method("_damage"):
		bodies_to_explode.append(body)

func _on_Area_body_exited(body) -> void:
	if body in bodies_to_explode:
		bodies_to_explode.erase(body)

