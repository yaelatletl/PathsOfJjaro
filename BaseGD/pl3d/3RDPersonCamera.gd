extends KinematicBody

# class member variables go here, for example:
var linear_velocity = Vector3()
var gravity = Vector3()
var Target = Vector3()
var originalpos = Vector3()
var origin = Vector3()
var cameramovement
func _ready():
	gravity = get_parent().get_parent().gravity
	cameramovement = get_node("../..").fixpos

func _process(delta):
	linear_velocity = move_and_slide(linear_velocity,-gravity.normalized())
	Target = get_node("../../target").translation
	origin = get_node("../../CameraOrigin")
	translation.x = clamp(translation.x, Target.x-5, Target.x+5)
	translation.y = clamp(translation.y, Target.y-5, Target.y+5)
	translation.z = clamp(translation.z, Target.z-5, Target.z+5)
	
	
	
	if translation != Vector3(-0.001374,0.516047,1.64668) and not (is_on_floor() or is_on_ceiling() or is_on_wall()):
		if translation.x <= -0.001374-0.2:
			translation.x = translation.x + delta
		if translation.x >= -0.001374+0.2:
			translation.x = translation.x - delta
			
		if translation.y <= 0.516047-0.2:
			translation.y = translation.y + delta
		if translation.y >= 0.516047+0.2:
			translation.y = translation.y - delta
			
		if translation.z <= 1.64668-0.2:
			translation.z = translation.z + delta
		if translation.z >= 1.64668+0.2:
			translation.z = translation.z - delta	
			
	
