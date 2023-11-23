extends CharacterBody3D
class_name Player

# Player.gd


# removed SO model as it is not needed for solo campaigns except when looking at a reflective surface so can be added at the end as a stretch goal or left out if time is tight; until then, it only gets in the way

# TBH I am unclear on purpose of vertical head and feet raycasts as names are vague and code is undocumented and is referenced from movement.gd

const INPUT_AXIS_MULTIPLIER := 40


# TO DO: these are copied directly from M3 physics so currently use Classic WU and need converted to meters

const WALK_PHYSICS := {
	"maximum_forward_velocity": 1.0 * INPUT_AXIS_MULTIPLIER, # 0.07142639, # TO DO: for now, multiply all velocity-related fields by 14 to get values relative to forward walk speed (we can figure out the final multiplier to emulate M2 speeds later)
	"maximum_backward_velocity": 0.82 * INPUT_AXIS_MULTIPLIER, # 0.05882263,
	"maximum_perpendicular_velocity": 0.7 * INPUT_AXIS_MULTIPLIER, # 0.049987793,
	
	"acceleration": 0.004989624,
	"deceleration": 0.009994507,
	
	"airborne_deceleration": 0.005554199,
	"gravitational_acceleration": 0.0024871826,
	"climbing_acceleration": 0.003326416,
	"terminal_velocity": 0.14285278,
	"external_deceleration": 0.004989624,
	
	"angular_acceleration": 0.625,
	"angular_deceleration": 1.25,
	"maximum_angular_velocity": 6.0,
	"angular_recentering_velocity": 0.75,
	"fast_angular_velocity": 21.333328,
	"fast_angular_maximum": 128.0,
	
	"maximum_elevation": 42.666656,
	"external_angular_deceleration": 0.33332825,
	"step_delta": 0.049987793,
	"step_amplitude": 0.099990845,
	
	"radius": 0.25,
	"height": 0.7999878,
	
	"dead_height": 0.25,
	"camera_height": 0.19999695,
	"splash_height": 0.5,
	"half_camera_separation": 0.03125,
}


const SPRINT_PHYSICS := {
	"maximum_forward_velocity": 1.75 * INPUT_AXIS_MULTIPLIER, # 0.125,
	"maximum_backward_velocity": 1.16 * INPUT_AXIS_MULTIPLIER, # 0.08332825,
	"maximum_perpendicular_velocity": 1.08 * INPUT_AXIS_MULTIPLIER, # 0.076919556,
	
	"acceleration": 0.009994507,
	"deceleration": 0.019989014,
	
	"airborne_deceleration": 0.005554199,
	"gravitational_acceleration": 0.0024871826,
	"climbing_acceleration": 0.004989624,
	"terminal_velocity": 0.14285278,
	"external_deceleration": 0.004989624,
	
	"angular_acceleration": 1.25,
	"angular_deceleration": 2.5,
	"maximum_angular_velocity": 10.0,
	"angular_recentering_velocity": 1.5,
	"fast_angular_velocity": 21.333328,
	"fast_angular_maximum": 128.0,
	
	"maximum_elevation": 42.666656,
	"external_angular_deceleration": 0.33332825,
	"step_delta": 0.049987793,
	"step_amplitude": 0.099990845,
	
	"radius": 0.25,
	"height": 0.7999878,
	
	"dead_height": 0.25,
	"camera_height": 0.19999695,
	"splash_height": 0.5,
	"half_camera_separation": 0.03125,
}


const CROUCH_PHYSICS := WALK_PHYSICS # finish walk and sprint first, then implement crouch




# Physics variables
var gravity : float = 10 # Gravity force #45 is okay, don't change it 
var air_friction : float = 50 # air friction # TO DO: use airborne_deceleration
var floor_friction : float = 250 # floor friction

var DEFAULT_GRAVITY = gravity
const MAX_STEP_HEIGHT := 0.4 # this looks too low; M2 steps can be ~0.3WU, which is ~0.6m

var coyote_time : float = 0.1 # the delay between walking off a ledge and starting to fall # TO DO: is this needed? given that M2 allows user some control over movement in xz plane, returning to the ledge might be a step-up movement; need to check AO code to see how it does it (i.e. after running off ledge, is it possible to reverse forwards/backwards movement to regain it? or is the only way to regain ledge to turn mid-air while falling and step-up onto it before the y delta exceeds MAX_STEP_HEIGHT?)
var elapsed_coyote_time : float = 0



const JUMP_Y_SPEED := 5.0 # temporary till we figure out jumping


var mass: float = 45 # think this is only used for imparting impulse to other movable bodies; presumably all other objects must have a `mass` property too





var impulse = Vector3.ZERO




# TO DO: any benefits to using signals here? any health changes can be sent from Player to HUD via method call
signal died()
signal health_changed(health, shields)

var health  := 100
var shields := 100




var wall_direction : Vector3 = Vector3.ZERO # used in VaultOver, do we need this? hopefully Player only needs a camera animation to imply jumping over a barrier



@onready var weapon_manager := $WeaponManager
# TO DO: InventoryManager for ammunition, keys, powerups, etc

# vertical collision detection using raycasting
@onready var head_clearance := $HeadClearance # crouching -> standing -> jumping
@onready var feet_clearance := $FeetClearance # TO DO: not sure about this one

@onready var head   := $head
@onready var body   := $body
@onready var camera := $head/camera






var is_sprint_enabled := false # TO DO: whereas Classic requires user to hold key constantly to SPRINT (or to WALK if sprinting is the default), let's try toggling between WALK/SPRINT states when user taps the key (note: crouching and swimming modes will eventually override this, hence '...enabled' as this property only records the toggle state)

# TO DO: we will need to decide on swimming behavior as M2's crude float/sink mechanic when SPRINT key is pressed/released is annoying: Wen submerged and FORWARD is pressed, should the Player always swim in the camera's direction? When no movement key is pressed, should Player hold position or start to sink?

var mouse_x_sensitivity := deg_to_rad(20.0) #0.2 # TO DO: need separate parameters for horizontal and vertical axes (user typically wants fast turn and slow vertical look, otherwise vertical aiming is difficult)
var mouse_y_sensitivity := deg_to_rad(5.0) #0.2 # TO DO: need separate parameters for horizontal and vertical axes (user typically wants fast turn and slow vertical look, otherwise vertical aiming is difficult)


const MAX_LOOK_ANGLE := deg_to_rad(85) # Maximum camera angle

var mouse_velocity := Vector2.ZERO # TO DO: is there any benefit to handing mouse motion _input events ourselves vs. calling Input.get_last_mouse_velocity() in _process?

func _input(event):
	if event is InputEventMouseMotion:
		mouse_velocity = event.relative


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # put this here for now, and MOUSE_MODE_VISIBLE in MainMenu._ready; TO DO: mouse capture/release logic can eventually move to Global (note: game should not have a Pause/Resume key [Ctrl-P in M2]; instead, provide a key for exiting the game world back to menu and save the game's current state as a temporary saved game file which is loaded and deleted when the game is next reentered)
	self.max_slides = 4 # oddly max_slides doesn't appear in Editor's CharacterBody3D inspector
	#self.floor_stop_on_slope_enabled = false # this does, however
	#self.floor_max_angle = PI / 4 # as does this



func _process(delta: float) -> void:
	
	# TO DO: if Player is dead, disconnect inputs (i.e. player's corpse should move under its own physics only; no user input)
	
	# turn left/right (rotates Player around its y-axis)
	self.rotation.y += mouse_velocity.x * -mouse_x_sensitivity * delta # TO DO: clamp to ±MAX_TURN_SPEED
	# look down/up (rotates camera along its x-axis); note: do not implement Classic's camera looks left/right keys as those do not translate well to gamepad/touch controls and a user can strafe using existing controls
	var vertical_look = camera.rotation.x - (mouse_velocity.y * mouse_y_sensitivity) * delta
	camera.rotation.x = clamp(vertical_look, -MAX_LOOK_ANGLE, MAX_LOOK_ANGLE)
	mouse_velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed(&"NEXT_WEAPON"):
		weapon_manager.goto_next_weapon()
	elif Input.is_action_just_pressed(&"PREVIOUS_WEAPON"):
		weapon_manager.goto_previous_weapon()

	if Input.is_action_pressed(&"SHOOT_PRIMARY"):
		var aim := Vector3(camera.rotation.x, self.global_rotation.y, 0)
		weapon_manager.shoot_primary(self.global_position, aim)
	if Input.is_action_pressed(&"SHOOT_SECONDARY"):
		var aim := Vector3(camera.rotation.x, self.global_rotation.y, 0)
		weapon_manager.shoot_secondary(self.global_position, aim)
	
	# TO DO: ideally SHOOT_PRIMARY/SECONDARY would automatically perform action when facing control panel, but keep it separate for now
	if Input.is_action_pressed(&"ACTION"):
		pass





#Changed it a bit respecting to our regular movement, this one requires very specific colliders
#Otherwise the behaviour will be off and it wont be able to do platform-stair climbing
#Crouching most probably will be disabled, but implementation stays just in case


var input_axis := Vector2.ZERO # sidestep and forward/backward movements on xz plane
var y_speed := 0.0 # WIP: this is downward speed due to gravity but also upward speed when jumping


func _physics_process(delta: float) -> void:
	# TO DO: what's easiest way to disconnect all user inputs when player is dead/immobilized?
	
	if Input.is_action_just_pressed(&"SPRINT"): # toggle walk/sprint
		is_sprint_enabled = !is_sprint_enabled
	
	# TO DO: CROUCH will become automatic; leave on manual key for now
	if Input.is_action_just_pressed(&"CROUCH"):
		pass

	
	var physics = SPRINT_PHYSICS if is_sprint_enabled else WALK_PHYSICS # temporary until crouch+swim states are implemented
	
	var friction := air_friction
	if is_on_floor():
		input_axis = Input.get_vector(&"MOVE_BACKWARD", &"MOVE_FORWARD", &"MOVE_LEFT", &"MOVE_RIGHT")
		friction += floor_friction
		# TO DO: JUMP will become automatic, but leave on manual key for now
		if Input.is_action_just_pressed(&"JUMP") and not head_clearance.is_colliding(): # TO DO: do we need to check head clearance? or just jump and let physics deal with it?
			y_speed = JUMP_Y_SPEED
		else:
			y_speed = 0.0
		
	else:
		input_axis = Vector2.ZERO # in freefall, air slows horizontal movement; TO DO: is this close enough to Classic? (this only applies resistance to player's input vector; what about external impulse? how should an explosion that throws player into the air affect movement?); TO DO: what about vacuum levels? # TO DO: alternative is to treat floor contact 
		y_speed -= gravity * delta # TO DO
	
	# TO DO: it may be better to treat user input as another impulse that only operates on Player body when there is floor contact; the floor itself applies ground_friction which applies opposing force
	# if Player is falling, they can still look freely which allows them to turn mid-air (a Classic quirk we preserve as a gameplay feature)
	var look = self.global_transform.basis
	assert(look.y == Vector3.UP)
	var z_multiplier = physics.maximum_forward_velocity if input_axis.x > 0 else physics.maximum_backward_velocity
	var player_velocity: Vector3 = (look.z * -input_axis.x * z_multiplier) + (look.x * input_axis.y * physics.maximum_perpendicular_velocity)
	#
	# TO DO: decide swim mechanics later
	
	if 0: # TEST: move on user inputs only; no inertia or external forces
		self.velocity = player_velocity / 10
		self.velocity.y = y_speed
		self.move_and_slide()
		return
	
	
	# Interpolates between the current position and the future position of the character
	#Funny numbers, magic numbers. Wrong.
	var inertia = self.velocity.lerp(Vector3(), friction * delta)
	if inertia.length() >= 0.1:
		player_velocity += inertia
	
	# Applies interpolation to the velocity vector
	self.velocity = self.velocity.lerp(player_velocity, delta)
	self.velocity.y = y_speed
	
	# any external forces acting on Player
	if not impulse.is_zero_approx():
		self.velocity += impulse.lerp(Vector3.ZERO, delta) * delta
		impulse -= impulse.lerp(Vector3.ZERO, delta) * delta
	
	
	# TO DO: fix stair climbing
	
	#Stairs/ledge step check
	#Do a test move, check if the character could go up a step or down a step
	#check if the character would be stopped if going forward, then if it would be stopped if going forward and up. Then it should go up. 
	var test_transform = Transform3D(self.transform.basis, self.transform.origin + Vector3(0, MAX_STEP_HEIGHT, 0) + (self.velocity)* delta)
	var should_go_up = self.test_move(self.transform, self.velocity * delta) and not self.test_move(test_transform, self.velocity * delta)
	#Do a test move, check if the character could go down a step, if its linear velocity on the y axis is negative 
	#var can_move_down = self.test_move(self.transform, self.velocity * delta + Vector3(0, -MAX_STEP_HEIGHT, 0))
	self.velocity = self.velocity+Vector3(0,MAX_STEP_HEIGHT*delta,0) if should_go_up else self.velocity #- Vector3(0,MAX_STEP_HEIGHT,0) if can_move_down else self.velocity)
	#uncomment if we need to handle steps
	
	
	
	# using the MAX_STEP_HEIGHT variable
	# TODOConverter40 infinite_inertia were removed in Godot 4.0 - previous value `false`
	self.move_and_slide()
	
	
	
	return # temporary
	
	
	# TO DO: I think the purpose of this is last bit to bounce other bodies off player
	for index in self.get_slide_collision_count():
		var collision = self.get_slide_collision(index)
		if collision.get_collider(0) is RigidBody3D:
			if collision.get_collider(0) == feet_clearance.get_collider():
				return
			else:
				collision.get_collider(0).apply_central_impulse(
					(-collision.get_normal() * self.run_speed / collision.get_collider(0).mass) * delta)



	
func is_far_from_floor() -> bool: # TO DO: what is purpose of this? it is not the same as the built-in is_on_floor method
	return not feet_clearance.is_colliding()


func _damage(amount : float, type):
	var temp = amount
	amount = (amount - shields)/10
	shields -= temp
	if health > 0:
		health -= amount
	if health <= 0:
		die()
	emit_signal("health_changed", health, shields)

func die():
#	_get_component("input").enabled = false
	emit_signal("died")
	#print("Player "+name+" died")




func request_interact(interactable : Node3D, message : String, time : float = 0.0):
	pass
	#We need to pass the message to the HUD
#	if	_get_component("interactor"):
#		_get_component("interactor").request_interact(interactable, message, time)

func stop_interact():
	pass
#	if _get_component("interactor"):
#		_get_component("interactor").stop_interact()





func found_item(item) -> void:
	# if there is space in inventory for this item, pick it up
	item.picked_up()



#func _crouch(input : Dictionary, delta :float) -> void:
	# Inputs
	# Get the character's head node
	# If the head node is not touching the ceiling
#	if not head_clearance.is_colliding():
		
		# Takes the character collision node
		
		# change the character's collision shape
#		var shape = body.shape.height
#		shape = lerp(shape, 1.7 - (get_key(input, "crouch") * 1.5), WALK_SPEED  * delta)
#		body.shape.height = shape
#		body.shape.radius = (0.24 - 0.12*get_key(input, "crouch"))
		#separation_ray.shape.length = shape
#		feet.target_position.y = -shape



#func _sprint(input : Dictionary, delta : float) -> void:
	# Inputs
	# Make the character sprint
#	if not get_key(input, "crouch"): # If you are not crouching
		# switch between sprint and walking
#		self.reset_slide_multi()
#		var toggle_speed : float = WALK_SPEED + ((SPRINT_SPEED - WALK_SPEED) * get_key(input, "sprint")) #Normal Sprint Speed
		# Create a character speed interpolation
#		n_speed = lerp(n_speed, toggle_speed, 3 * delta)
#	else:
		# Create a character speed interpolation
#		self.velocity.y -= 0.1*self.run_speed*delta
#		if slide_on_crouch and self.run_speed>12 and not self.is_far_from_floor():
#			n_speed = lerp(n_speed, WALK_SPEED * self.multiplier , 15* delta)
#			self.multiplier = lerp(self.multiplier, 0.8, delta*20)
#		elif not self.is_far_from_floor():
#			n_speed = lerp(n_speed, CROUCH_SPEED, self.multiplier*delta)
#			self.reset_slide_multi()
#			self.reset_wall_multi()



func add_impulse(impulse_in : Vector3) -> void:
	impulse += impulse_in




# TO DO: dumping these functions here for now; they came from weapon code but aiming is performed by Player (player position and camera rotation); when the Player tells a WeaponTrigger to shoot, it should pass the player's global position and camera's global angle to the Trigger; the Trigger is responsible for adding any offset from player's (camera's?) center (e.g. rockets launch from left shoulder) to get projectile's point of origin, then instantiating a Projectile with that point of origin, camera angle, and projectile parameters (once attached to the scene tree, the projectile propels itself); for MCR we should not need anything more sophisticated than this
#func _position(_delta) -> void:
#	global_transform.origin = head.global_transform.origin
	
#func _rotation(_delta) -> void:
#	var y_lerp = 40
#	var quat_a = global_transform.basis.get_rotation_quaternion()
#	var quat_b = $head/camera.global_transform.basis.get_rotation_quaternion()
#	var x_lerp = 80
#	var angle_distance = quat_a.angle_to(quat_b)
#	if angle_distance < PI/2:
#		global_transform.basis = Basis(quat_a.slerp(quat_b, _delta*x_lerp*angle_distance))
#	else:
#		rotation = $head/camera.global_transform.basis.get_euler()

