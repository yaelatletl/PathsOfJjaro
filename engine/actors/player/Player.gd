extends CharacterBody3D
class_name Player

# Player.gd


# notes:
#
# - 810-dude tip: WiH are scaled down and moved completely inside Body radius close to camera to prevent gun barrels clipping through walls
#
# - for now, WeaponInHand scenes (assets) are attached directly to Player (engine) so they initialize and connect to Weapons when level is entered; they should eventually be attached to Player by code for loose coupling between engine and assets
#
# auto-jump and auto-crouch mechanics are provisional, for early play testing only; we will probably modify these further once levels are being built (there are lots of situations where we don't want auto-crouch triggered, e.g. when facing a moving door/platform)


# TODO: should step detection also detect descending stairs? ATM climbing stairs is smooth (player maintains traction in CLIMB_STEP) whereas descending may be a bit bumpy


# TODO: easiest way to implement ladder is to have ladder Area tell the body when it enters/exits the ladder; while on the ladder, translate forward/backward/sideways movement to up/down movement depending on whether player is looking at ladder (forward->up) or awfay from it (forward->down); also decide how/when to use FALL: should Player and NPCs always jump down shaft rather than controlled descent of ladder?


var __alive := true


# TODO: these are janky: the PHYSICS speeds bear little relation to in-game numbers

const JUMP_MIN_SPEED: float = 6.0 # PlayerDefinitions.SPRINT_PHYSICS.maximum_forward_velocity * 0.9 # player must be sprinting in order to jump

const JUMP_Y_SPEED := 5.0 # temporary till we figure out jumping; this just punts player vertically without considering angle of ascent

const CROUCH_MAX_SPEED: float = PlayerDefinitions.WALK_PHYSICS.maximum_forward_velocity * 0.2 # player must be almost stopped in order to crouch

const MAX_LOOK_ANGLE := deg_to_rad(85) # Maximum camera angle


# body parts

@onready var body   := $Body
@onready var head   := $Head
@onready var camera := $Head/Camera


# vertical collision detection using raycasting
@onready var head_clearance := $Head/HeadClearance # crouching -> standing -> jumping
@onready var feet_clearance := $FeetClearance # TODO: not sure about this one

# control panel detection
@onready var detect_control_panel := $Head/Camera/ActionReach


# step/ledge/crawlway detection 

# this uses a pair of vertical raycasts placed in front of player that extend downwards to ground and upwards to Player's head height (the exact ends may need some finessing); this should detect open-tread stairs (which forward-facing raycasts may miss), though might not reliably detect railings (which are narrow enough to fit in the gap between detector and player body)

# TODO: use ShapeCast3D? more expensive but should be better at detecting

const STEP_DETECTOR_OFFSET := 0.9 # distance from center of player at which to position the raycast's origin; is always calculated in the direction of movement on xz plane # TODO: should this distance be larger when sprinting?

@onready var step_detector := $StepDetector # this is always STEP_DETECTOR_OFFSET (0.8m) ahead of player center in direction of movement, which should be enough to detect approaching step/ladder/crouch/ledge/railing # note: this raycast only detects a collision body that MAY block player walking forward (e.g. it could be a smooth ramp, which is climbable by Player's capsule body up to a certain angle); it also doesn't guarantee that it won't return false if the player proceeds forward, moving the ray to other side of a narrow body (e.g. ladder tread); TODO: probably want 2 raycasts positioned left and right to better detect ledges approached at an angle; these will need to rotate around the Player's y=0 axis

@onready var crawlway_ceiling_detector := $CrouchedBody/CeilingDetector # this is always 0.1m in front of Player
@onready var crawlway_floor_detector   := $CrouchedBody/FloorDetector # quick-n-dirty check; TODO: use shape cast to determine if player is facing a crawlable duct
@onready var crouch_animation          := $CrouchedBody/AnimationPlayer
@onready var crouch_timer              := $CrouchedBody/Timer # once crouching starts, wait until timeout before uncrouching


# movement states

enum HorizontalMovement {
	
	CRAWL, # crouching
	WALK,
	SPRINT,
	AIRBORNE, # movement is decoupled (turning is still allowed) and horizontal speed is dependent on air friction and collisions only
	# SWIM,
}

var horizontal_movement: HorizontalMovement = HorizontalMovement.SPRINT


func __update_horizontal_movement() -> void:
	match vertical_movement:
		VerticalMovement.FALL, VerticalMovement.JUMP, VerticalMovement.VAULT:
			horizontal_movement = HorizontalMovement.AIRBORNE
			# TODO: what should current_physics be? (does it matter?) for now, it is whatever physics was in use before going airborne
			
		VerticalMovement.CLIMB_LADDER:
			horizontal_movement = HorizontalMovement.CRAWL # TODO: need to decide how user movement translates to climb/descend (on both vertical and slanted ladders)
			current_physics = PlayerDefinitions.CRAWL_PHYSICS
		_:
			if is_crouch_enabled:
				horizontal_movement = HorizontalMovement.CRAWL
				current_physics = PlayerDefinitions.CRAWL_PHYSICS
			elif is_sprint_enabled:
				horizontal_movement = HorizontalMovement.SPRINT
				current_physics = PlayerDefinitions.SPRINT_PHYSICS
			else:
				horizontal_movement = HorizontalMovement.WALK
				current_physics = PlayerDefinitions.WALK_PHYSICS



enum VerticalMovement { # Player states are TBD; not yet implemented
	NONE,
	CLIMB_STEP,
	CLIMB_LADDER,
	FALL,
	JUMP,
	VAULT,
	#SWIM,
	#SINK,
}

var vertical_movement := VerticalMovement.NONE


func __set_vertical_movement(new_movement: VerticalMovement) -> void:
	vertical_movement = new_movement
	match new_movement:
		VerticalMovement.NONE:
			y_speed = 0.0
		
		VerticalMovement.CLIMB_STEP:
			pass
		
		VerticalMovement.CLIMB_LADDER:
			pass
		
		VerticalMovement.FALL:
			pass
		
		VerticalMovement.JUMP:
			y_speed = JUMP_Y_SPEED
		
		VerticalMovement.VAULT:
			pass
	
	__update_horizontal_movement()




var mass := 45.0 # think this is only used for imparting impulse to other movable bodies (elastic collisions); presumably all other objects must have a `mass` property too (RigidBody3D has `mass` property built in)


var coyote_time : float = 0.1 # the delay between walking off a ledge and starting to fall # TODO: is this needed? given that M2 allows user some control over movement in xz plane, returning to the ledge might be a step-up movement; need to check AO code to see how it does it (i.e. after running off ledge, is it possible to reverse forwards/backwards movement to regain it? or is the only way to regain ledge to turn mid-air while falling and step-up onto it before the y delta exceeds MAX_STEP_HEIGHT?)
var elapsed_coyote_time : float = 0




var current_physics: Dictionary


var impulse = Vector3.ZERO

var wall_direction : Vector3 = Vector3.ZERO # used in VaultOver, do we need this? hopefully Player only needs a camera animation to imply jumping over a barrier


var xz_input := Vector2.ZERO # sidestep and forward/backward movements on xz plane
var y_speed := 0.0 # WIP: this is downward speed due to gravity but also upward speed when jumping

var climb_direction := Vector3.ZERO
var detected_step = null
var detected_step_top := 0.0


var mouse_x_sensitivity := deg_to_rad(20.0) #0.2 # TODO: need separate parameters for horizontal and vertical axes (user typically wants fast turn and slow vertical look, otherwise vertical aiming is difficult)
var mouse_y_sensitivity := deg_to_rad(5.0) #0.2 # TODO: need separate parameters for horizontal and vertical axes (user typically wants fast turn and slow vertical look, otherwise vertical aiming is difficult)

var mouse_velocity := Vector2.ZERO # TODO: is there any benefit to handing mouse motion _input events ourselves vs. calling Input.get_last_mouse_velocity() in _process?

var debug_view := false



var is_sprint_enabled := true: # toggles between walk and sprint each time SPRINT key is pressed
	get:
		return is_sprint_enabled
	set(new_value):
		is_sprint_enabled = new_value
		__update_horizontal_movement()


# crouch; this reduces Player body to sphere (radius is unchanged) and reduces xz velocity to crawl speed
var is_crouch_enabled := false:
	get:
		return is_crouch_enabled
	set(new_value):
		print("is_crouch_enabled=", new_value)
		if not crouch_animation.is_playing():
			is_crouch_enabled = new_value
			__update_horizontal_movement()
			if new_value:
				crouch_timer.start()
				crouch_animation.play("crouch", -1, +1.0, false)
			else:
				crouch_animation.play("crouch", -1, -1.0, true)


func get_step_name() -> String:
	if detected_step:
		return detected_step.get_parent().name
	else:
		return ""


func global_head_position() -> Vector3:
	return head.global_position

func global_look_direction() -> Vector3:
	return camera.global_transform.basis.z * -1

func global_feet_y() -> float:
	return self.global_position.y - body.shape.height / 2

func global_feet_position() -> Vector3:
	return Vector3(self.global_position.x, global_feet_y(), self.global_position.z)

func horizontal_speed() -> float:
	var v = Vector3(self.velocity)
	v.y = 0
	return v.length()

func has_traction() -> bool:
	return is_on_floor() or vertical_movement == VerticalMovement.CLIMB_STEP

func is_far_from_floor() -> bool:
	# @hhas01: TODO: what is purpose of this? it is not the same as the built-in is_on_floor method
	# @810-Dude answers: There are some functions implemented to fix some quirks of the engine, 
	# like the function feet_clearance, that one exists due to that the function is_on_floor 
	# won't work unless move_and_slide is being called and the object moves. 
	# So certain static situations needed it. Perhaps now we don't, but it's something to consider
	return not feet_clearance.is_colliding()



func set_horizontal_movement_text(text: String) -> void: # DEBUG
	#print("horizontal_movement: ", text)
	$Canvas/HUD.set_horizontal_movement_text(text)

func set_vertical_movement_text(text: String) -> void: # DEBUG
	#print("vertical_movement: ", text)
	$Canvas/HUD.set_vertical_movement_text(text)



func _ready() -> void:
	self.scale = Vector3(0.96, 0.96, 0.96) # Player is built to dimensions (1.0,1.6,1.0) to keep its math simple, but needs to squeeze through ~1.0m gaps so reduce Player's size slightly here to allow clearance
	self.max_slides = 4 # oddly max_slides doesn't appear in Editor's CharacterBody3D inspector
	#self.floor_stop_on_slope_enabled = false # this does, however
	#self.floor_max_angle = PI / 4 # as does this
	__alive = true
	Global.health_changed.connect(update_health_status)
	Global.player_died.connect(update_health_status)
	__set_vertical_movement(VerticalMovement.NONE)
	__update_horizontal_movement()
	update_health_status()
	WeaponManager.activate_current_weapon(true) # TODO: this is temporary until we have proper level loading, at which point we can decide how/when/where to get everything ready
	Global.enter_level()


# user input processing, Player actions and movement

func _input(event):
	if event is InputEventMouseMotion:
		mouse_velocity = event.relative


func process_action_inputs() -> void:
		# DEBUG: quick-n-dirty chase cam view; note: weapons and Action raycast are attached to Camera so won't look/behave correctly when camera is behind Player
		if Input.is_action_just_pressed(&"DEBUG_CAMERA"):
			debug_view = not debug_view
			$BodyMarker.visible = debug_view
			camera.position.z = 3 if debug_view else 0
		# shoot
		if Input.is_action_just_pressed(&"NEXT_WEAPON"):
			WeaponManager.activate_next_weapon()
		elif Input.is_action_just_pressed(&"PREVIOUS_WEAPON"):
			WeaponManager.activate_previous_weapon()
		if Input.is_action_pressed(&"SHOOT_PRIMARY"):
			WeaponManager.current_weapon.shoot(self, true)
		if Input.is_action_pressed(&"SHOOT_SECONDARY"):
			WeaponManager.current_weapon.shoot(self, false)
		if Input.is_action_just_released(&"SHOOT_PRIMARY"):
			WeaponManager.current_weapon.trigger_just_released(true)
		if Input.is_action_just_released(&"SHOOT_SECONDARY"):
			WeaponManager.current_weapon.trigger_just_released(false)
		# action
		if detect_control_panel.is_colliding():
			if Input.is_action_just_pressed(&"ACTION"):
				var control_panel = detect_control_panel.get_collider()
				control_panel.do_action(self)
				# TODO: some control panels require start+stop action (e.g. recharger immediately stops charging if player moves)


func get_user_movement(delta:float) -> Vector3:
	assert(current_physics)
	# mouse look
	# turn left/right (rotates Player around its y-axis)
	self.rotation.y += mouse_velocity.x * -mouse_x_sensitivity * delta # TODO: clamp to ±maximum_angular_velocity
	# look down/up (rotates camera along its x-axis)
	var vertical_look = camera.rotation.x - (mouse_velocity.y * mouse_y_sensitivity) * delta
	camera.rotation.x = clamp(vertical_look, -MAX_LOOK_ANGLE, MAX_LOOK_ANGLE)
	mouse_velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed(&"TOGGLE_SPRINT"): # toggle walk/sprint
		is_sprint_enabled = not is_sprint_enabled
	
	# TODO: CROUCH will become automatic; leave on manual key for now
	#if Input.is_action_just_pressed(&"CROUCH"):
	#	self.is_crouch_enabled = true
	#elif Input.is_action_just_released(&"CROUCH"):
	#	self.is_crouch_enabled = false # TODO: also need to confirm player has head clearance to stand; should this be is_crouch_enabled?
	
	# movement
	if has_traction(): # player has traction while on ground/stairs/ladders/ledge-jump TODO: see comment on is_far_from_floor about its reliability
		if vertical_movement >= VerticalMovement.FALL:
			__set_vertical_movement(VerticalMovement.NONE)
		xz_input = Input.get_vector(&"MOVE_LEFT", &"MOVE_RIGHT", &"MOVE_BACKWARD", &"MOVE_FORWARD")
		# TODO: JUMP will become automatic, but leave on manual key for now
		#if Input.is_action_just_pressed(&"JUMP") and not head_clearance.is_colliding(): # TODO: do we need to check head clearance? or just jump and let physics deal with it?
		#	__set_vertical_movement(VerticalMovement.JUMP)
	else:
		match vertical_movement:
			VerticalMovement.CLIMB_LADDER:
				pass # TODO: translate xz_input to climb/descend; Q. what if player is facing away from ladder: descend/climb? or fall?
			
			VerticalMovement.JUMP:
				pass
				
			_:
			#if y_speed < 0 and not vertical_movement == VerticalMovement.CLIMB_LADDER: # TODO: decide descending ladder behavior (should player climb down or jump down?)
			#	vertical_movement = VerticalMovement.FALL
				xz_input = Vector2.ZERO
				var prev_y_speed = y_speed
				y_speed -= current_physics.gravity * delta # TODO: does vacuum/air/liquid make a difference here?
				if prev_y_speed >= 0 and y_speed < 0:
					__set_vertical_movement(VerticalMovement.FALL)
	
	# if Player is falling, they can still look freely which allows them to turn mid-air (a Classic quirk we preserve as a gameplay feature)
	var look = self.global_transform.basis
	#assert(look.y.normalized() == Vector3.UP)
	var z_multiplier = current_physics.maximum_forward_velocity if xz_input.y > 0 else current_physics.maximum_backward_velocity
	return (look.z * -xz_input.y * z_multiplier) + (look.x * xz_input.x * current_physics.maximum_perpendicular_velocity)



# physics processing

func _physics_process(delta: float) -> void:
	var player_velocity := Vector3.ZERO # the direction the player is moving
	var desired_direction := Vector3.ZERO # the direction the user input wants player to move; this influences the step detector's positioning more than the player's velocity so that if e.g. the player is sliding along a wall, the step detector will face into the wall, not be parallel to it, and so will detect a step at end of that wall
	
	if __alive:
		player_velocity = get_user_movement(delta)
		process_action_inputs()
		# user's desired direction of movement; influences the step detector's position
		desired_direction.x = player_velocity.x
		desired_direction.z = player_velocity.z
		
		if 0: # TEST: move on user inputs only; no inertia or external forces
			self.velocity = player_velocity / 10
			self.velocity.y = y_speed
			self.move_and_slide()
			return
	
	# Interpolates between the current position and the future position of the character
	#Funny numbers, magic numbers. Wrong.
	var friction: float = current_physics.air_friction
	if has_traction():
		friction += current_physics.floor_friction
	var inertia = self.velocity.lerp(Vector3(), friction * delta)
	if inertia.length() >= 0.1:
		player_velocity += inertia
	
	# Applies interpolation to the velocity vector
	self.velocity = self.velocity.lerp(player_velocity, delta) # tends towards 0 without reaching it...
	if self.velocity.length() < 0.05: # ...so check it; caution: this must be less than crawling speeds
		self.velocity = Vector3.ZERO
	self.velocity.y = y_speed # includes gravity when standing on floor; appropriate?
	
	# any external forces acting on Player
	if not impulse.is_zero_approx():
		self.velocity += impulse.lerp(Vector3.ZERO, delta) * delta
		impulse -= impulse.lerp(Vector3.ZERO, delta) * delta # TODO: ditto?
	
	
	var v = self.velocity#.normalized()
	var w = desired_direction#.normalized()
	set_horizontal_movement_text("%s  %s\n%0.2f,%0.2f,%0.2f\n%0.2f,%0.2f,%0.2f" % [Global.enum_to_string(horizontal_movement, HorizontalMovement), Global.enum_to_string(vertical_movement, VerticalMovement), v.x, v.y, v.z, w.x, w.y, w.z])
	
	if is_crouch_enabled:
		if crouch_timer.is_stopped() and not head_clearance.is_colliding() and not crawlway_ceiling_detector.is_colliding():
			print("head clearance: ", head_clearance.is_colliding())
			self.is_crouch_enabled = false
			set_vertical_movement_text("")
	else:
		# automatic step climb, ledge jump, and crouch; TODO: can this also detect vault reliably? (we may need a forward pointing ray for that since railings are narrow)
		# StepDetector preferentially orients in direction the user wants to move, falling back to direction player is moving under inertia if no user inputs, falling back to direction player is looking if no movement
		# TODO: if input keys are released just before step, player may slide along side of a step under inertia only (without user input, the step detector orients in the collide-and-slide direction); is this acceptable? or should we capture the previous velocity before the collision and compare the two, using the previous velocity if a step is detected?
		var move_x = self.velocity.x + desired_direction.x * 20
		var move_z = self.velocity.z + desired_direction.z * 20
		var horizontal_direction := Vector3(move_x, 0, move_z).normalized() if move_x or move_z else global_look_direction()
		horizontal_direction.y = 0
		step_detector.global_position = self.global_position + horizontal_direction * STEP_DETECTOR_OFFSET
		
		# TODO: if ceiling and floor detectors are both colliding, use the difference between them (i.e. player should be able to crawl into a duct as long as it isn't above step [jump?] height); the alternative would be to explicitly indicate crouch+crawl locations within levels using Areas (similar to how ladders are explicitly marked as Areas); this could work well enough in gameplay and will prevent unwanted crouches (we'll have enough to worry about preventing unwanted jumps, though again we might use explicit Area markers to trigger a +y impulse where the player needs to leap a gap)
		if not is_crouch_enabled and crawlway_ceiling_detector.is_colliding() and not crawlway_floor_detector.is_colliding() and horizontal_speed() <= CROUCH_MAX_SPEED:
			# TODO: do not crouch in front of a moving platform/door, or when standing on a moving platform (caveat: we might want to make level 4's trash compactor exit a duct, requiring player to punch out grille and crawl in before they get crushed; we might get around that by pausing compactor platform briefly as large garbage objects press against ceiling)
			# TODO: use shape cast to confirm there is a crawlable hole
			set_vertical_movement_text("crouching\nduct-height=%0.2f" % (crawlway_ceiling_detector.get_collision_point().y - crawlway_floor_detector.get_collision_point().y))
			self.is_crouch_enabled = true
		
		if step_detector.is_colliding():
			match vertical_movement:
				VerticalMovement.CLIMB_STEP:
					continue_climb()
				VerticalMovement.JUMP:
					pass # do nothing
				_:
					start_climb()
		
		elif vertical_movement == VerticalMovement.CLIMB_STEP: # was climbing # TODO: this needs to be more selective; it may stop colliding because Player is sliding against step
			if global_feet_y() >= detected_step_top or y_speed <= 0: # has Player cleared the step/started falling?
				print("stop climbing ", get_step_name())
				stop_climb()
				detected_step = null
		
		elif vertical_movement == VerticalMovement.JUMP:
			if global_feet_y() >= detected_step_top or y_speed <= 0:
				print("stop jumping ", get_step_name())
				stop_climb()
				detected_step = null
	
	
	self.move_and_slide()
	
	
	return # temporary until last collision detection below is sorted out
	
	# TODO: I think the purpose of this is last bit to bounce movable bodies off player (elastic collisions); every movable body is responsible for doing this (since any body can bounce off any other body), so move this logic into its own shared function if practical (that being said, we should also check if Godot physics can do this automatically for non-character bodies)
	for index in self.get_slide_collision_count():
		var collision = self.get_slide_collision(index)
		if collision.get_collider(0) is RigidBody3D: # what's best way to differentiate immovable vs movable bodies here? note that every mobile body is responsible for doing this
			if collision.get_collider(0) == feet_clearance.get_collider():
				return
			else:
				collision.get_collider(0).apply_central_impulse(
					(-collision.get_normal() * self.run_speed / collision.get_collider(0).mass) * delta)


# climb/jump

func start_climb() -> void: # TODO: also check head clearance?
	detected_step = step_detector.get_collider()
	var col_point = step_detector.get_collision_point()
	detected_step_top = col_point.y
	var step_height := detected_step_top - global_feet_y()
	print("start of step or ledge: ", get_step_name())
	var speed = horizontal_speed()
	
	if step_height <= current_physics.max_step_height:
		__set_vertical_movement(VerticalMovement.CLIMB_STEP)

		climb_direction = (col_point - global_feet_position()).normalized() # not the right launch vector as it doesn't account for gravity or air friction (although currently we don't use the vector)
		
		set_vertical_movement_text("start climbing step\n%s\n%s" % [get_step_name(), climb_direction])
		
		self.velocity.y = speed * climb_direction.y * 2
		
	elif step_height <= current_physics.max_jump_height:
		if vertical_movement != VerticalMovement.JUMP:
			if speed >= JUMP_MIN_SPEED: # TODO: we only want to jump if player is sprinting and user is pressing forward key; Q. should pressing forward + sidestep also be permitted? (jumping backwards is not)
				climb_direction = (col_point - global_feet_position()).normalized() # not the right launch vector as it doesn't account for gravity or air friction (although currently we don't use the vector)
				set_vertical_movement_text("start jumping\n%s\n%s" % [get_step_name(), climb_direction])
				y_speed = JUMP_Y_SPEED * 3
				self.velocity.y = y_speed
				__set_vertical_movement(VerticalMovement.JUMP)
			else:
				set_vertical_movement_text("can't auto-jump (too slow) speed=%0.2f < %0.2f" % [speed, JUMP_MIN_SPEED])
		else:
			set_vertical_movement_text("can't double-jump")
	else:
		set_vertical_movement_text("can't climb/jump (too high)")


func continue_climb() -> void:
	var step = step_detector.get_collider()
	if step != detected_step: # found a new step so start climbing that
		detected_step = step
		detected_step_top = step_detector.get_collision_point().y
		set_vertical_movement_text("Detected next step or ledge: %s" % get_step_name())
		start_climb()
	else:
		self.velocity.y = horizontal_speed() * climb_direction.y * 2


func stop_climb():
	__set_vertical_movement(VerticalMovement.NONE) # wrong, probably
	#self.velocity.y = 0 # rather abrupt
	climb_direction = Vector3.ZERO
	set_vertical_movement_text("stop climbing: %s" % get_step_name())



# external impulse, e.g. applied by a detonation's shrapnel radius or by firing rocket launcher

func add_impulse(impulse_in : Vector3) -> void:
	impulse += impulse_in



# called by PickableItem when it detects Player walking into it

func found_item(item: PickableItem) -> void: # called by PickableItem when Player collides with it (we'll keep this flexible just in case we want any NPCs to grab items as well)
	# if there is space in inventory for this item, pick it up
	if InventoryManager.get_item(item.pickable_type).try_to_increment():
		item.picked_up()
		$Audio/PickedUp.play() # TODO: we don't want to couple assets/audio directly to Player; need some sort of API between them


# InventoryManager signal handlers

func update_health_status(damage_type: Enums.DamageType = Enums.DamageType.NONE) -> void:
	if damage_type != Enums.DamageType.NONE:
		pass # TODO: damage effect animations, e.g. Player may "sway" or "stagger" when hit, which is a camera animation (the Player itself won't move)


func player_died(_damage_type: Enums.DamageType) -> void:
	__alive = false
	# TODO: death effect: camera drops to ground (use crouch dimensions for dead player, although it'll need a different animation), colliders and inputs are disabled
	# note: don't bother implementing player_revived: solo games will reload the entire Level scene from last savepoint; ignore netplay respawning for now


# TODO: camera shake is a useful visual effect, e.g. when smacked by a Hulk or when something explodes nearby, or maybe when player hits ground hard after jumping from great height

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




# TODO: leaving these functions here for now; they came from previous weapon code but aiming is done by Player (although we do want to rotate projectiles that have 3D meshes so the projectile always points in direction of travel)
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


#func _animation() -> void: # this animates head bob when walking/sprinting
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



#func _tilt(_delta : float) -> void: # do we want tilt? it's getting a bit far away from Classic gameplay look and feel; OTOH, if we swap the sidestep and turn axes for touch controls (so the primary joystick provides forward/backward + turning, which allows user's other thumb to press primary trigger while player moves around tank-style), having the secondary (sidestep + v-look) joystick lean player left/right when sidestepping could make it more intuitive (i.e. using the "look" joystick to "lean left/right" activates sidestepping)
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

