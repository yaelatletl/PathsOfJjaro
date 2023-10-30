extends NavigationAgent3D

@onready var actor = get_parent()

func _ready():
	actor._register_component("navigation", self)
	var max_vel = null
	if actor.has_method("_get_component"):
		max_vel = actor._get_component("movement_basic")
		if max_vel:
			max_speed = max_vel.w_speed
			

func _physics_process(delta):
	set_velocity(actor.linear_velocity) #How fast am I going?
	#get_next_location() #Returns next direction, gotta call it from the input planner



#func get_path_to_point(point_to : Vector3):
#	set_target_location(point_to) # we need to use this one, seems it's a direct conversion, 

