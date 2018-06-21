extends Area
var prev_grav = 0
var c_grav = Vector3(0,1,0)
var storage = []

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
	
	#Starts gravity vector calculation.
	c_grav = c_grav.rotated(xaxis,deg2rad(rotation_degrees.x))
	c_grav = c_grav.rotated(yaxis,deg2rad(rotation_degrees.y))
	c_grav = c_grav.rotated(zaxis,deg2rad(rotation_degrees.z))
	c_grav = c_grav*-gravity
	#Gravity vectors calculation ends. 
	

func _on_body_entered(object):
	if object is KinematicBody and object.get("grav") != null:
		var obj_ID = object.get_instance_id()
		if storage.size() <= obj_ID:
			storage.resize(obj_ID)
		prev_grav = Vector3(object.gravity.x,object.gravity.y,object.gravity.z)
		storage.insert(obj_ID,prev_grav) #Store the previous gravity value of the current object.
		object.gravity = c_grav
		
func _on_body_exited(object):
	if object is KinematicBody and object.get("grav") != null:
		var ext_ID = object.get_instance_id()
		object.gravity = storage[ext_ID] #Sets gravity to it's original default
		

