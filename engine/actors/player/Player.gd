extends CharacterBody3D
class_name Player

# Player.gd


const INPUT_AXIS_MULTIPLIER := 10 # temporary until we decide on final values in physics dictionaries below


# TO DO: these are copied directly from M3 physics so currently use Classic WU and need converted to meters


# TO DO: Boomer maps have low gravity flag, but I assume we can get the same effect by loading a different physics?


# TO DO: Player currently uses CapsuleShape to detect floor; at what point does capsule slide off a ledge? (not sure what M2's collision cylinder does - it might remain on ledge as long as any part of its base remains in contact; capsule is useful as it can push player out from wall so the model doesn't appear to slide down wall partly embedded in it; we might want to add a smaller cylinder to bottom of capsule to widen it a bit; also need to decide on player's Projectile/Explosion hit box, which may be a slightly narrower capsule or cylinder; there is also Player-NPC collisions to consider, which may need a wider collision cylinder to prevent NPC models' extremities appearing embedded in Player when both bodies are very close/touching)


# TO DO: player speed when running up/down ramps should be similar/same to player speed running up/down stairs, which should be similar to Classic player on stairs (if up and down ramp speeds are the same, SeparationRayShape3D at bottom of player body can provide that; not sure how that will behave around stairs though)



const WALK_PHYSICS := {
	"maximum_forward_velocity": 1.0 * INPUT_AXIS_MULTIPLIER, # 0.07142639, # TO DO: for now, multiply all velocity-related fields by 14 to get values relative to forward walk speed (we can figure out the final multiplier to emulate M2 speeds later)
	"maximum_backward_velocity": 0.82 * INPUT_AXIS_MULTIPLIER, # 0.05882263,
	"maximum_perpendicular_velocity": 0.7 * INPUT_AXIS_MULTIPLIER, # 0.049987793,
	
	"acceleration": 0.004989624,
	"deceleration": 0.009994507,
	"climbing_acceleration": 0.003326416,
	
	"angular_acceleration": 0.625, # I think this is y-axis rotation
	"angular_deceleration": 1.25, # ditto
	"maximum_angular_velocity": 6.0, # ditto
	"angular_recentering_velocity": 0.75, # TO DO: how quickly the camera vertically auto-recenters when moving forward/backward (note: moving sideways does not auto-recenter)
	
	"radius": 0.25,
	"height": 0.7999878,
	"camera_height": 0.19999695, # TO DO: I think this is deducted from height
	"splash_height": 0.5, # TO DO: I assume this puts waterline around waist when swimming on surface of liquid
	
	# will the following be same for all gaits? what about swimming?
	
	"airborne_deceleration": 0.005554199, # applies to xz plane (AFAIK)
	"gravitational_acceleration": 0.0024871826, # applies to y axis
	"terminal_velocity": 0.14285278, # applies to y-axis 
	"external_deceleration": 0.004989624, # not sure about this: friction acting against xz motion?
	"external_angular_deceleration": 0.33332825, # not sure
	
	#"fast_angular_velocity": 21.333328, # head turn, so ignore it (strafing's the usual tactic for spraying bullets in one direction while moving in another and doesn't need extra keys)
	#"fast_angular_maximum": 128.0,
	
	# camera bob, I think
	"step_delta": 0.049987793, # units? (looks like seconds? it's not ticks) M2 uses the exact same camera bounce at both walk and sprint; not sure if we want walk to have slightly different bounce to visually differentiate gaits; crawl and swim will use different values; what about low-gravity?; TO DO: should we use M2 Physics params or hardcoded AnimationPlayer tracks to control camera bounce? (AP has advantage that play only needs called at transitions whereas code-based bounce requires extra code in _physics_process to update it; one advantage of code is when player stops at any point in bounce: animation track has to run to end of sequence to reset height, although we could use AP and switch to a timer-based function to reduce current bounce height)
	"step_amplitude": 0.099990845,
	
	"dead_height": 0.25,
	"half_camera_separation": 0.03125, # FOV
	"maximum_elevation": 42.666656, # vertical look limit (±42.7deg is the Classic value, which was determined less by gameplay than by need to avoid visual distortion due to the Classic renderer's lack of true verticals; while we probably want to constrain the angle to some degree to avoid changing gameplay too much - e.g. near-vertical look allows user unlimited freedom to snipe from ledges whereas Classic forced user to jump down to shoot monsters directly below - we might allow a somewhat greater angle, e.g. ±60-70deg, for a more modern gameplay feel)
}


const SPRINT_PHYSICS := {
	"maximum_forward_velocity": 1.75 * INPUT_AXIS_MULTIPLIER * 1.3, # 0.125, # TO DO: check Player.linear_velocity is increased by 175% when sprinting vs walking (currently sprinting feels a bit slow)
	"maximum_backward_velocity": 1.16 * INPUT_AXIS_MULTIPLIER * 1.3, # 0.08332825,
	"maximum_perpendicular_velocity": 1.08 * INPUT_AXIS_MULTIPLIER * 1.3, # 0.076919556,
	
	"acceleration": 0.009994507,
	"deceleration": 0.019989014,
	"climbing_acceleration": 0.004989624,
	
	"angular_acceleration": 1.25,
	"angular_deceleration": 2.5,
	"maximum_angular_velocity": 10.0,
	"angular_recentering_velocity": 1.5,
	
	"radius": 0.25,
	"height": 0.7999878,
	"camera_height": 0.19999695,
	"splash_height": 0.5,
	
	# same for all gaits?
	
	"airborne_deceleration": 0.005554199,
	"gravitational_acceleration": 0.0024871826,
	"terminal_velocity": 0.14285278,
	"external_deceleration": 0.004989624,
	"external_angular_deceleration": 0.33332825,
	
	#"fast_angular_velocity": 21.333328,
	#"fast_angular_maximum": 128.0,
	
	"step_delta": 0.049987793,
	"step_amplitude": 0.099990845,
	
	"dead_height": 0.25,
	"half_camera_separation": 0.03125,
	"maximum_elevation": 42.666656,
}


const JUMP_Y_SPEED := 5.0 # temporary till we figure out jumping


const CROUCH_PHYSICS := WALK_PHYSICS # finish walk and sprint first, then implement crouch; note that jump and crouch should be mutually exclusive


enum Movement {
	IDLE,
	WALK,
	SPRINT,
	JUMP,
	CRAWL,
	CLIMB,
	SWIM,
}


var current_movement := Movement.IDLE





# Physics variables
var gravity : float = 10 # Gravity force #45 is okay, don't change it 
var air_friction : float = 50 # air friction # TO DO: use airborne_deceleration
var floor_friction : float = 250 # floor friction


const MAX_STEP_HEIGHT := 0.4 # this looks too low; M2 steps can be ~0.3WU, which is ~0.6m


var coyote_time : float = 0.1 # the delay between walking off a ledge and starting to fall # TO DO: is this needed? given that M2 allows user some control over movement in xz plane, returning to the ledge might be a step-up movement; need to check AO code to see how it does it (i.e. after running off ledge, is it possible to reverse forwards/backwards movement to regain it? or is the only way to regain ledge to turn mid-air while falling and step-up onto it before the y delta exceeds MAX_STEP_HEIGHT?)
var elapsed_coyote_time : float = 0




var mass: float = 45 # think this is only used for imparting impulse to other movable bodies; presumably all other objects must have a `mass` property too (RigidBody3D has `mass` property built in)

var impulse = Vector3.ZERO




# TO DO: any benefits to using signals here? any health changes can be sent from Player to HUD via method call
signal died()
signal health_changed(health, shields)


var health  := 100
var shields := 100




var wall_direction : Vector3 = Vector3.ZERO # used in VaultOver, do we need this? hopefully Player only needs a camera animation to imply jumping over a barrier



# vertical collision detection using raycasting
@onready var head_clearance := $HeadClearance # crouching -> standing -> jumping
@onready var feet_clearance := $FeetClearance # TO DO: not sure about this one

@onready var head   := $head
@onready var body   := $body
@onready var camera := $head/camera

@onready var detect_control_panel := $head/camera/ActionReach





var input_axis := Vector2.ZERO # sidestep and forward/backward movements on xz plane
var y_speed := 0.0 # WIP: this is downward speed due to gravity but also upward speed when jumping


var is_sprint_enabled := false # TO DO: whereas Classic requires user to hold key constantly to Sprint key, let's make WALK/SPRINT states toggle when user taps the TOGGLE_SPRINT key (note: crouching and swimming modes will eventually override this, hence '...enabled' as this property only records the toggle state)

# TO DO: we will need to decide on swimming behavior as M2's crude float/sink mechanic when TOGGLE_SPRINT key is pressed/released is annoying: Wen submerged and FORWARD is pressed, should the Player always swim in the camera's direction? When no movement key is pressed, should Player hold position or start to sink?

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






func _physics_process(delta: float) -> void: # fixed interval (see Project Settings > General > Physics > Common > Physics FPS, which is currently set to 120fps)
	# if Player is dead, disconnect inputs (i.e. player's corpse should move under its own physics only; no user input); what's easiest way to do this? (maybe checking if dead and skipping over everything except gravitational, external impulse, and inertial movement, aka flying gibs)
	var player_velocity := Vector3.ZERO
	var friction := air_friction
	if health > 0:
		
		# mouse look
		# turn left/right (rotates Player around its y-axis)
		self.rotation.y += mouse_velocity.x * -mouse_x_sensitivity * delta # TO DO: clamp to ±MAX_TURN_SPEED
		# look down/up (rotates camera along its x-axis); note: do not implement Classic's camera looks left/right keys as those do not translate well to gamepad/touch controls and a user can strafe using existing controls
		var vertical_look = camera.rotation.x - (mouse_velocity.y * mouse_y_sensitivity) * delta # TO DO: should head rotate instead of camera? that allows walk/sprint bounce to control camera's height without changing aiming or ActionReach raycast (currently, bouncing the camera will cause these to move vertically as well; Q. how does M2 do it? is bounce 100% cosmetic or does it affect aim too? and does the bounce delta have an appreciable effect?) alternatively, could change bounce animation to operate on Camera3D.y_offset instead of position as (AFAIK) that only moves the viewport
		camera.rotation.x = clamp(vertical_look, -MAX_LOOK_ANGLE, MAX_LOOK_ANGLE)
		mouse_velocity = Vector2.ZERO
		
		# shoot
		if Input.is_action_just_pressed(&"NEXT_WEAPON"):
			Inventory.next_weapon()
		elif Input.is_action_just_pressed(&"PREVIOUS_WEAPON"):
			Inventory.current_weapon.previous_weapon()
		if Input.is_action_pressed(&"SHOOT_PRIMARY"):
			Inventory.current_weapon.shoot_primary(self.global_position, camera.global_rotation, self)
		if Input.is_action_pressed(&"SHOOT_SECONDARY"):
			Inventory.shoot_secondary(self.global_position, camera.global_rotation, self)
		
		# action
		if detect_control_panel.is_colliding():
			# TO DO: ideally SHOOT_PRIMARY and/or SHOOT_SECONDARY would automatically perform action when facing control panel, but keep it separate for now
			# TO DO: when player is inside ACTION range, consider playing a hand animation to the show secondary hand poised to press the control when SHOOT_SECONDARY is pressed: this makes it clear to user when the trigger key's behavior is toggled between SHOOT and ACTION, although this is somewhat complicated by dual-wield pistol (since hand needs to retain pistol while pressing button, the animation needs to rotate hand+pistol to press switch with bottom of grip/back of hand), fusion/AR/shotgun (secondary trigger normally fires a switch-activating projectile, so we need to differentiate destructible circuits from normal control panels - in this case if the circuit is in ACTION range then simplest is just to play a punch animation)
			# we'd also need to avoid the player accidentally grenading/spnkring themselves when hunting for hidden doors or otherwise attempting to activate a switch while moving past it, so this definitely needs more thought (if we can't make it work safely, we'll have to keep a separate ACTION key, which is acceptable for keyboard and gamepad control but not ideal for 2-thumbed touch control)
			if Input.is_action_just_pressed(&"ACTION"):
				var control_panel = detect_control_panel.get_collider()
				control_panel.do_action(self)
				# TO DO: some control panels require start+stop action (e.g. recharger immediately stops charging if player moves)
		
		
		if Input.is_action_just_pressed(&"TOGGLE_SPRINT"): # toggle walk/sprint
			is_sprint_enabled = not is_sprint_enabled
			# TO DO: how to indicate current movement speed on screen? e.g. toggle radar's background image? (touch control can toggle the walk/sprint button's icon, but that button is hidden for keyboard and gamepad controls so the primary walk/sprint indicator needs to be immediately obvious to the user's eye at all times)
		
		# TO DO: CROUCH will become automatic; leave on manual key for now
		if Input.is_action_just_pressed(&"CROUCH"):
			pass

		# movement
		var physics = SPRINT_PHYSICS if is_sprint_enabled else WALK_PHYSICS # temporary until crouch+swim states are implemented
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
			y_speed -= gravity * delta # TO DO: does vacuum/air/liquid make a difference here?
			# TO DO: if Player is hard against step when JUMP is activated, they will need some forward movement while in air to step onto it (there's no point applying it until they have sufficient height to clear it, otherwise physics reduces forward movement to 0); OTOH, we don't want jumping and then pressing forward to start moving them forward while airborne; this needs some thought, although since jumping will be activated automatically perhaps we should start thinking about how jumps will be triggered when running at a jumpable ledge and at what distance and angle
		
		# TO DO: it may be better to treat user input as another impulse that only operates on Player body when there is floor contact; the floor itself applies ground_friction which applies opposing force
		# if Player is falling, they can still look freely which allows them to turn mid-air (a Classic quirk we preserve as a gameplay feature)
		var look = self.global_transform.basis
		assert(look.y == Vector3.UP)
		var z_multiplier = physics.maximum_forward_velocity if input_axis.x > 0 else physics.maximum_backward_velocity
		player_velocity = (look.z * -input_axis.x * z_multiplier) + (look.x * input_axis.y * physics.maximum_perpendicular_velocity)
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
	
	
	# TO DO: fix stair climbing; the Player (and NPCs) should follow a straight-ish diagonal line when running up stairs, so either needs to take off at a distance or treat stairs differently wrt collision detection (I suspect the bottom-leading edge of M2's simple collision cylinder intersects edges of steps, with each step imparting enough vertical momentum that the bottom of the cylinder's vertical axis just clears it, or possibly that the M2 player, upon detecting an intersection of cylinder and floor, automatically rises to stand on top of it)
	#
	# AFAIK the best way to do stair climbing in Godot (for Player and NPCs) is to add a pair of forward raycasts to the character, one just above the character's max step height (stepable detector) and the other at ground (kerb detector): if top raycast is clear and bottom raycast collides with Level or FixedScenery then add vertical impulse to start the climb; hopefully we can generalize this mechanism to support auto-jump (jumpable and clearable detectors), auto-crouch (crouchable detector), and auto-vault (railing detector) as well; note that kerb detection won't work on stairs with open treads, so might need to use a vertical raycast, or possibly try an Area with cylinder shape to detect all ledges near feet
	#
	# one caveat: how well will a single point raycast detect stairs when approaching at a shallow angle of incidence? do we need to add extra rays to the center ray's left and right?
	#
	# might be of help:
	#
	# https://www.youtube.com/watch?v=ILVUc_yV24g
	#
	# https://godotengine.org/asset-library/asset/2278
	
	#Stairs/ledge step check
	#Do a test move, check if the character could go up a step or down a step
	#check if the character would be stopped if going forward, then if it would be stopped if going forward and up. Then it should go up. 
	#var test_transform = Transform3D(self.transform.basis, self.transform.origin + Vector3(0, MAX_STEP_HEIGHT, 0) + (self.velocity) * delta)
	#var should_go_up = self.test_move(self.transform, self.velocity * delta) and not self.test_move(test_transform, self.velocity * delta)
	#Do a test move, check if the character could go down a step, if its linear velocity on the y axis is negative 
	#var can_move_down = self.test_move(self.transform, self.velocity * delta + Vector3(0, -MAX_STEP_HEIGHT, 0))
	#self.velocity = self.velocity + Vector3(0, MAX_STEP_HEIGHT * delta, 0) if should_go_up else self.velocity #- Vector3(0,MAX_STEP_HEIGHT,0) if can_move_down else self.velocity)
	
	
	self.move_and_slide()
	
	
	
	return # temporary
	
	# TO DO: I think the purpose of this is last bit to bounce movable bodies off player (elastic collisions); every movable body is responsible for doing this (since any body can bounce off any other body), so move this logic into its own shared function if practical (that being said, we should also check if Godot physics can do this automatically for non-character bodies)
	for index in self.get_slide_collision_count():
		var collision = self.get_slide_collision(index)
		if collision.get_collider(0) is RigidBody3D: # what's best way to differentiate immovable vs movable bodies here? note that every mobile body is responsible for doing this
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





#func _animation() -> void: # this animates head bob when walking/sprinting; TO DO: get rid of this and play bob animations in Player
	
	# If the player presses the jump button
#	if character.input["jump"]:
		# Checks if the jump animation is active
#		if current_animation != "jump":
			# Starts the jump animation
#			play("jump", 0.3)

	# If the character is moving
#	if character.direction:
		# If the current animation is not a walk
#		if current_animation != "jump":
#			if character.input["sprint"]:
#				if current_animation != "sprint":
#					play("sprint", 0.3, 1.5)
#			else:
#				if current_animation != "walk":
#					play("walk", 0.3)
#	else:
#		# If the current animation is not idle
#		if current_animation != "idle" and current_animation != "jump":
			# Starts animation with smoothing
#			play("idle", 0.3, 0.1)


# TO DO: camera shake is a useful visual effect, e.g. when smacked by a Hulk or when something explodes nearby, or maybe when player hits ground hard after jumping from great height

@export var shake_time := 0.0
@export var shake_force := 0.0

func shake_camera(_delta : float) -> void:
	if shake_time > 0:
		camera.h_offset = randf_range(-shake_force, shake_force)
		camera.v_offset = randf_range(-shake_force, shake_force)
		shake_time -= _delta
	else:
		camera.h_offset = 0
		camera.v_offset = 0


# 
#func _tilt(_delta : float) -> void:
	#wall_normal.normal is in global space, wall_normal is an object! 
	#camera forward/back is basis.z 
	#given a wall normal, tilt the camera to the opposite side of the wall
#	if actor.wall_normal != null and actor.is_on_wall() and actor.linear_velocity.length() > 5 and actor.is_far_from_floor():
#		var rotation_angle = global_transform.basis.z.cross(actor.wall_normal.get_normal()*10.0).y
#		if not is_zero_approx(rotation_angle):
#			if rotation_angle < 0.0:
#				rotation.z = lerp(rotation.z, 2.0, _delta)
#			else:
#				rotation.z  = lerp(rotation.z, -2.0, _delta)
#	elif shake_time <= 0:
#		rotation.z = lerp(rotation.z, 0.0, _delta) 

