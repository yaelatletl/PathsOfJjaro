extends Area
var prev_grav = 0
var c_grav = Vector3(0,1,0)


const yaxis = Vector3(0,1,0)
const xaxis = Vector3(1,0,0)
const zaxis = Vector3(0,0,1)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	connect("body_entered",self,"_on_body_entered")
	connect("body_exited",self,"_on_body_exited")
	space_override = SPACE_OVERRIDE_COMBINE_REPLACE
	#c_grav= euler_to_vector(rotation_degrees).normalized()*gravity
	c_grav = c_grav.rotated(xaxis,deg2rad(rotation_degrees.x))
	c_grav = c_grav.rotated(yaxis,deg2rad(rotation_degrees.y))
	c_grav = c_grav.rotated(zaxis,deg2rad(rotation_degrees.z))
	c_grav = c_grav*-gravity
	

func _on_body_entered(object):
	if object is KinematicBody and object.get("grav") != null:
		#prev_grav = float(object.gravity)
		object.gravity=c_grav
		
func _on_body_exited(object):
	if object is KinematicBody and object.get("grav") != null:
		object.gravity=Vector3(0,-9.8,0) #This must be changed, intstead of setting the gravity to -9.8 set it to it's last default.
		
func euler_to_vector(vector):
	var newvector = Vector3(0,0,0)
	newvector.x =  sin(deg2rad(vector.y)) * cos(deg2rad(vector.x))
	newvector.y =  sin(deg2rad(vector.y)) * cos(deg2rad(vector.x))
	newvector.z =  sin(deg2rad(vector.x))
	return newvector
