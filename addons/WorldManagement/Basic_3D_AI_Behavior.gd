extends KinematicBody



#AI Characteristics
export(bool) var static_AI = false
export(int) var Team = 0
export(bool) var is_worker = false
export(int) var indifference = 10
export(float) var smellarea = 5
export(float) var health = 100
export(float) var speedfactor = 0.4
#time for timersx
export(int) var timewaiting = 2


#Movement Values
export(bool) var flies = false
export(float) var weight = 1
export(float) var max_speed = 10
export(int) var turn_speed = 40
export(float) var accel = 19.0
export(float) var deaccel = 14.0
export(bool) var keep_jump_inertia = true
export(bool) var air_idle_deaccel = false
export(float) var JumpHeight = 7.0
export(float) var grav = 9.8

#Globals
var initialized = false
var on_workstation = false
var workstation_near = false
var player_near = false
var is_on_sight = false
var visible_obj

var position =Vector3(0,0,0)
var randposition =Vector3(0,0,0)
var linear_velocity = Vector3()
var gravity = Vector3(0,-grav,0)
var sharp_turn_threshold = 140
var jump_attempt = false
var jumping = false
var globaldelta = 0.0
var CHAR_SCALE = Vector3(1, 1, 1)
var is_moving = false


	
func _ready():
	add_child(preload("res://addons/WorldManagement/3D_AI.tscn").instance())
	$AI/Wait.wait_time = timewaiting
	$AI/Senses/SmellandHear/CollisionShape.shape.radius = smellarea
	var groups = get_groups()
	visible_obj = $AI/Senses/SmellandHear/Eyes
	set_process(true)

	Spatial_Routine()
	CHAR_SCALE = scale
	initialized = true


func Spatial_Routine():
	#idle()
	$AI/Wait.connect("timeout", self, "switch_waiting")
	#$AI/Hunt.connect("timeout", self, "Hunting")
	#$AI/Work.connect("timeout", self, "Work")
	$AI/Wander.connect("timeout", self, "new_position")
	$AI/Senses/SmellandHear.connect("area_entered", self, "check_area")
	$AI/Senses/SmellandHear.connect("body_entered", self, "check_body")
	#Spatial_Routine()

func switch_waiting():
	if is_moving:
		is_moving = false
		pass
	else:
		is_moving = true
		pass
func Work():
	if on_workstation:
		do_work()
	else:
		walk()

func Hunting():
	if player_near and not static_AI:
		Chase()
	else:
		if is_on_sight:
			attack()



func check_area(object):
	for x in object.get_groups():
		print(to_global(object.translation))
		print(object.translation)
		if x == "Workstation" and is_worker and indifference==10:
			print("access")
			position = object.translation
			workstation_near = true
		if x == "Workstation" and is_worker and (indifference >= 1 and indifference <=5):
			#Killenemies()
			position = object.translation
			workstation_near = true
		if x == "Workstation" and is_worker and indifference == 0:
			#Killallenemies()
			position = object.translation
			workstation_near = true
func check_body(object):
	pass

func wander():
	if workstation_near:
		var vectorpos = (position-translation).normalized()
		Spatial_move_to(vectorpos, globaldelta)
	else:
		Spatial_move_to(randposition, globaldelta)

func Spatial_move_to(vector,delta):
	if not flies:
		linear_velocity += gravity*delta/weight

	var up = -gravity.normalized() # (up is against gravity)
	var vertical_velocity = up.dot(linear_velocity) # Vertical velocity
	var horizontal_velocity = linear_velocity - up*vertical_velocity # Horizontal velocity
	var hdir = horizontal_velocity.normalized() # Horizontal direction
	var hspeed = horizontal_velocity.length()*speedfactor

	#look_at(vector, Vector3(0,1,0)) #Change to something that turns to the player or something they have to see

	var target_dir = (vector - up*vector.dot(up)).normalized()

	if (is_on_floor()): #Only lets the character change it's facing direction when it's on the floor.
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold

		if (vector.length() > 0.1 and !sharp_turn):
			if (hspeed > 0.001):
				#linear_dir = linear_h_velocity/linear_vel
				#if (linear_vel > brake_velocity_limit and linear_dir.dot(ctarget_dir) < -cos(Math::deg2rad(brake_angular_limit)))
				#	brake = true
				#else
				hdir = RAD.adjust_facing(hdir, target_dir, delta, 1.0/hspeed*turn_speed, up)
				var facing_dir = hdir

			else:
				hdir = target_dir


			if (hspeed < max_speed):
				hspeed += accel*delta
		else:
			hspeed -= deaccel*delta
			if (hspeed < 0):
				hspeed = 0

		horizontal_velocity = hdir*hspeed


		var mesh_xform = get_transform()
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - up*facing_mesh.dot(up)).normalized()

		if (hspeed>0):
			facing_mesh = RAD.adjust_facing(facing_mesh, target_dir, delta, 1.0/hspeed*turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)

		set_transform(Transform(m3, mesh_xform.origin))

		if (not jumping and jump_attempt):
			vertical_velocity = JumpHeight
			jumping = true
			#get_node("sound_jump").play()
	else:
		if (vector.length() > 0.1):
			horizontal_velocity += target_dir*accel*delta
			if (horizontal_velocity.length() > max_speed):
				horizontal_velocity = horizontal_velocity.normalized()*max_speed
		else:
			if (air_idle_deaccel):
				hspeed = hspeed - (deaccel*0.2)*delta
				if (hspeed < 0):
					hspeed = 0

				horizontal_velocity = hdir*hspeed

	if (jumping and vertical_velocity < 0):
		jumping = false
	if not flies:
		linear_velocity = horizontal_velocity + up*vertical_velocity
	else:
		linear_velocity = horizontal_velocity

	if (is_on_floor()):
		var movement_dir = linear_velocity

	linear_velocity = move_and_slide(linear_velocity,-gravity.normalized())

func _process(delta):
	globaldelta = delta
	if is_moving:
		wander()


func new_position():
	randposition = Vector3(rand_range(-10,10),rand_range(-10,10),rand_range(-10,10))

func AI_is_seeing():
	if visible_obj.is_colliding():
		var obj_seen_grps = visible_obj.get_collider().get_groups()
		for x in obj_seen_grps:
			if x == "Workstation" and is_worker:
				Spatial_move_to(visible_obj.get_collider()._get("global_transform"),globaldelta)
			else:
				var WorkPos = to_global(visible_obj.get_collider().transform)
				Spatial_move_to(WorkPos, globaldelta)
				break

func attack():
	pass