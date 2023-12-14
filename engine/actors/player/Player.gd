extends CharacterBody3D
class_name Player

# Player.gd


# important:
#
# WiH is scaled down and moved completely inside Body radius close to camera to prevent clipping through walls
#
# for now, WIH (assets) are attached directly to Player (engine) so they initialize and connect to Weapons when level is entered; this also allows them to be positioned in-camera in the 3D view; eventually, they should attach programatically to avoid asset->engine coupling




const INPUT_AXIS_MULTIPLIER := 15 # temporary until we decide on final values in physics dictionaries below


# TO DO: Boomer (Pfhor ship) maps have a low gravity flag, but I assume we can get the same effect by loading a different physics model for those levels? (really don't want lots of flag modifiers)



# TO DO: in 3D Physics layers, rename "Level" to Map/MapGeometry/Wall/Surface/Solid/Exterior/Architecture/Shell or something else that's descriptive as "Level" is unhelpful (in mapping terms, a Level is the map geometry *and* all of the objects inside it)

# TO DO: Player currently uses CapsuleShape to detect floor; at what point does capsule slide off a ledge? (not sure what M2's collision cylinder does - it might remain on ledge as long as any part of its base remains in contact; capsule is useful as it can push player out from wall so the model doesn't appear to slide down wall partly embedded in it; we might want to add a smaller cylinder to bottom of capsule to widen it a bit; also need to decide on player's Projectile/Explosion hit box, which may be a slightly narrower capsule or cylinder; there is also Player-NPC collisions to consider, which may need a wider collision cylinder to prevent NPC models' extremities appearing embedded in Player when both bodies are very close/touching)


# TO DO: player speed when running up/down ramps should be similar/same to player speed running up/down stairs, which should be similar to Classic player on stairs (if up and down ramp speeds are the same, SeparationRayShape3D at bottom of player body can provide that; not sure how that will behave around stairs though)



# TO DO: these were copied from M3 physics so need converted to Godot quantities; most properties have yet to be connected to implementation

# TO DO: finish these dictionaries then move them to PlayerPhysicsDefinitions

const WALK_PHYSICS := {
	"maximum_forward_velocity": 1.0 * INPUT_AXIS_MULTIPLIER, # 0.07142639, # TO DO: for now, multiply all velocity-related fields by 14 to get values relative to forward walk speed (we can figure out the final multiplier to emulate M2 speeds later)
	"maximum_backward_velocity": 0.82 * INPUT_AXIS_MULTIPLIER, # 0.05882263,
	"maximum_perpendicular_velocity": 0.7 * INPUT_AXIS_MULTIPLIER, # 0.049987793,
	
	
	# TO DO: these aren't currently hooked up
	
	"acceleration": 0.004989624,
	"deceleration": 0.009994507,
	"climbing_acceleration": 0.003326416,
	
	"angular_acceleration": 0.625, # I think this is y-axis rotation
	"angular_deceleration": 1.25, # ditto
	"maximum_angular_velocity": 6.0, # ditto
	"angular_recentering_velocity": 0.75, # TO DO: how quickly the camera vertically auto-recenters when moving forward/backward (note: moving sideways does not auto-recenter)
	
	"radius": 0.245,
	"height": 0.79,
	"head_height": 0.3,
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
	
	"radius": 0.245,
	"height": 0.79,
	"head_height": 0.3,
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



const CROUCH_PHYSICS := {
	"maximum_forward_velocity": 0.5 * INPUT_AXIS_MULTIPLIER, # 0.07142639, # TO DO: for now, multiply all velocity-related fields by 14 to get values relative to forward walk speed (we can figure out the final multiplier to emulate M2 speeds later)
	"maximum_backward_velocity": 0.3 * INPUT_AXIS_MULTIPLIER, # 0.05882263,
	"maximum_perpendicular_velocity": 0.3 * INPUT_AXIS_MULTIPLIER, # 0.049987793,
	
	"acceleration": 0.004989624,
	"deceleration": 0.009994507,
	"climbing_acceleration": 0.003326416,
	
	"angular_acceleration": 0.625,
	"angular_deceleration": 1.25,
	"maximum_angular_velocity": 6.0,
	"angular_recentering_velocity": 0.75,
	
	"radius": 0.245,
	"height": 0.49,
	"head_height": 0.25,
	"splash_height": 0.5,
	
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


enum Movement {
	STATIONARY,
	WALK,
	SPRINT,
	JUMP,
	FALL,
	CROUCH,
	CLIMB,
	SWIM,
	SINK,
	DYING,
	DEAD,
	TELEPORT_IN,
	TELEPORT_OUT,
}

var current_movement := Movement.STATIONARY # TO DO: Player should know which state it's in (e.g. major-fist needs to know if player is sprinting or falling - we can't just use difference between player and npc velocities as a fast-moving enemy that runs into player's fist only receives minor-fist damage if player is standing or walking); this needs more thought (e.g. a player in CROUCH may be moving or stopped, so that probably needs separate CROUCH_IDLE and CROUCH_move) and we need to decide if some states can be entered before the current state exits (e.g. player could jump and crouch to get into a raised duct so this may require JUMP_CROUCH)



# Physics variables; TO DO: define in dictionaries above
var gravity : float = 10 # Gravity force #45 is okay, don't change it 
var air_friction : float = 50 # air friction # TO DO: use airborne_deceleration
var floor_friction : float = 250 # floor friction

var mass: float = 45 # think this is only used for imparting impulse to other movable bodies; presumably all other objects must have a `mass` property too (RigidBody3D has `mass` property built in)



const MAX_STEP_HEIGHT := 0.5 # this looks too low; M2 steps can be ~0.3WU, which is ~0.6m (Q. where is max step height defined in Classic/AO)

const MAX_JUMP_HEIGHT := 0.75 # this looks too low; M2 steps can be ~0.3WU, which is ~0.6m (Q. where is max step height defined in Classic/AO)

var coyote_time : float = 0.1 # the delay between walking off a ledge and starting to fall # TO DO: is this needed? given that M2 allows user some control over movement in xz plane, returning to the ledge might be a step-up movement; need to check AO code to see how it does it (i.e. after running off ledge, is it possible to reverse forwards/backwards movement to regain it? or is the only way to regain ledge to turn mid-air while falling and step-up onto it before the y delta exceeds MAX_STEP_HEIGHT?)
var elapsed_coyote_time : float = 0



var impulse = Vector3.ZERO

var wall_direction : Vector3 = Vector3.ZERO # used in VaultOver, do we need this? hopefully Player only needs a camera animation to imply jumping over a barrier


@onready var      body   := $Body
@onready var      head   := $Head # not sure if we need this node?
@onready var main_camera := $Head/Camera


# vertical collision detection using raycasting
@onready var head_clearance := $HeadClearance # crouching -> standing -> jumping
@onready var feet_clearance := $FeetClearance # TO DO: not sure about this one

# control panel detection
@onready var detect_control_panel := $Head/Camera/ActionReach


# step/ledge/crawlway detection 

# this uses a pair of vertical raycasts placed in front of player that extend downwards to ground and upwards to Player's head height (the exact ends may need some finessing); this should detect open-tread stairs (which forward-facing raycasts may miss), though might not reliably detect railings (which are narrow enough to fit in the gap between detector and player body)

# TO DO: use ShapeCast3D? more expensive but should be better at detecting

const STEP_DETECTION_OFFSET := 0.8 # distance from center of player at which to position the raycast's origin; is always calculated in the direction of movement on xz plane

@onready var forward_clearance := $ForwardClearance # this is always 0.8m ahead of player in direction of movement, which should be enough to detect approaching step/ladder/crouch/ledge/railing

@onready var duck_detector     := $ForwardClearance/DuckDetector
@onready var step_detector     := $ForwardClearance/StepDetector # note: this raycast only detects a collision body that MAY block player walking forward (e.g. it could be a smooth ramp, which is climbable by Player's capsule body up to a certain angle); it also doesn't guarantee that it won't return false if the player proceeds forward, moving the ray to other side of a narrow body (e.g. ladder tread); TO DO: probably want 2 raycasts positioned left and right to better detect ledges approached at an angle; these will need to rotate around the Player's y=0 axis
#
# once a collision is initially detected, we'll want some way of determining if it's a climbable step, jumpable ledge, smooth ramp (doesn't need special handling), or non-climable (e.g. it's too small/shallow/steeply sloped to stand on, e.g. wall greebles are ignored but greeble-like structures in the Level layer will be detected); for now, use a single raycast while getting the basic implementation working
#
# there are also ladders to consider, although those will probably have their own Layer and collision Area and can hopefully be built as self-contained assets with the necessary logic to enable Player and pathfinding NPCs to climb them
#
# TO DO: hit_from_inside=true but ray doesn't detect solid full-height walls in front of it (i.e. ray starts from inside the wall's collision box) - why?





var input_axis := Vector2.ZERO # sidestep and forward/backward movements on xz plane
var y_speed := 0.0 # WIP: this is downward speed due to gravity but also upward speed when jumping

var climb_direction   := Vector3.ZERO
var climb_destination := Vector3.ZERO


var is_sprint_enabled := false # TO DO: whereas Classic requires user to hold key constantly to Sprint key, let's make WALK/SPRINT states toggle when user taps the TOGGLE_SPRINT key (note: crouching and swimming modes will eventually override this, hence '...enabled' as this property only records the toggle state)

# TO DO: we will need to decide on swimming behavior as M2's crude float/sink mechanic when TOGGLE_SPRINT key is pressed/released is annoying: Wen submerged and FORWARD is pressed, should the Player always swim in the camera's direction? When no movement key is pressed, should Player hold position or start to sink?

var mouse_x_sensitivity := deg_to_rad(20.0) #0.2 # TO DO: need separate parameters for horizontal and vertical axes (user typically wants fast turn and slow vertical look, otherwise vertical aiming is difficult)
var mouse_y_sensitivity := deg_to_rad(5.0) #0.2 # TO DO: need separate parameters for horizontal and vertical axes (user typically wants fast turn and slow vertical look, otherwise vertical aiming is difficult)


const MAX_LOOK_ANGLE := deg_to_rad(85) # Maximum camera angle

var mouse_velocity := Vector2.ZERO # TO DO: is there any benefit to handing mouse motion _input events ourselves vs. calling Input.get_last_mouse_velocity() in _process?


var detected_step = null


var __alive := true


var global_look: Vector3:
	get:
		return main_camera.global_transform.basis.z * -1



func _ready() -> void:
	WeaponManager.activate_weapon_now(Enums.WeaponType.ASSAULT_RIFLE)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # put this here for now, and MOUSE_MODE_VISIBLE in MainMenu._ready; TO DO: mouse capture/release logic can eventually move to Global (note: game should not have a Pause/Resume key [Ctrl-P in M2]; instead, provide a key for exiting the game world back to menu and save the game's current state as a temporary saved game file which is loaded and deleted when the game is next reentered)
	self.max_slides = 4 # oddly max_slides doesn't appear in Editor's CharacterBody3D inspector
	#self.floor_stop_on_slope_enabled = false # this does, however
	#self.floor_max_angle = PI / 4 # as does this
	__alive = true
	Global.health_changed.connect(update_health_status)
	Global.player_died.connect(update_health_status)
	update_health_status()


# Inventory signals

func update_health_status(damage_type: Enums.DamageType = Enums.DamageType.NONE) -> void:
	if damage_type != Enums.DamageType.NONE:
		pass # TO DO: damage effect animations, e.g. Player may "sway" or "stagger" when hit, which is a camera animation (the Player itself won't move)


func player_died(_damage_type: Enums.DamageType) -> void:
	__alive = false
	# TO DO: death effect: camera drops to ground, colliders and inputs are disabled


# user input processing, Player actions and movement

func _input(event):
	if event is InputEventMouseMotion:
		mouse_velocity = event.relative


func _physics_process(delta: float) -> void: # fixed interval (see Project Settings > General > Physics > Common > Physics FPS, which is currently set to 120fps)
	# if Player is dead, disconnect inputs (i.e. player's corpse should move under its own physics only; no user input); what's easiest way to do this? (maybe checking if dead and skipping over everything except gravitational, external impulse, and inertial movement, aka flying gibs)
	var player_velocity := Vector3.ZERO
	var user_direction  := Vector3.ZERO # the direction the user is trying to move
	var friction := air_friction
	if __alive:
		# mouse look
		# turn left/right (rotates Player around its y-axis)
		self.rotation.y += mouse_velocity.x * -mouse_x_sensitivity * delta # TO DO: clamp to ±MAX_TURN_SPEED
		# look down/up (rotates camera along its x-axis); note: do not implement Classic's camera looks left/right keys as those do not translate well to gamepad/touch controls and a user can strafe using existing controls
		var vertical_look = main_camera.rotation.x - (mouse_velocity.y * mouse_y_sensitivity) * delta # TO DO: should head rotate instead of camera? that allows walk/sprint bounce to control camera's height without changing aiming or ActionReach raycast (currently, bouncing the camera will cause these to move vertically as well; Q. how does M2 do it? is bounce 100% cosmetic or does it affect aim too? and does the bounce delta have an appreciable effect?) alternatively, could change bounce animation to operate on Camera3D.y_offset instead of position as (AFAIK) that only moves the viewport
		main_camera.rotation.x = clamp(vertical_look, -MAX_LOOK_ANGLE, MAX_LOOK_ANGLE)
		mouse_velocity = Vector2.ZERO
		
		# TO DO: shoot keys need to move after move_and_slide so that projectile's origin matches player's position when next frame is drawn (right now shooting and sidestepping shows bullet originating from left or right instead of center)
		
		# shoot
		if Input.is_action_just_pressed(&"NEXT_WEAPON"):
			WeaponManager.next_weapon()
		elif Input.is_action_just_pressed(&"PREVIOUS_WEAPON"):
			WeaponManager.previous_weapon()
		if Input.is_action_pressed(&"SHOOT_PRIMARY"): # note: while key is held down, this will call shoot_primary on each tick; the weapon and its trigger will only fire when ready to do so
			WeaponManager.current_weapon.shoot_primary(self) # TO DO: should we pass the camera's global transform and let Projectile do the math?
		if Input.is_action_pressed(&"SHOOT_SECONDARY"):
			WeaponManager.current_weapon.shoot_secondary(self)
		
		if Input.is_action_just_released(&"SHOOT_PRIMARY"):
			WeaponManager.current_weapon.stop_shooting_primary()
		if Input.is_action_pressed(&"SHOOT_SECONDARY"):
			WeaponManager.current_weapon.stop_shooting_secondary()
		
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
		if has_traction():
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
		
		# bias step detector's position so that it is a combination of Player's move-and-slide velocity and the direction the user input is telling the Player to move (if only self.velocity is used, the step detector will be positioned in direction of movement, so if player is hard against a step sliding along it the detector doesn't intersect the edge of the step)
		user_direction.x = player_velocity.x
		# TO DO: what about vertical look?
		user_direction.z = player_velocity.z
		
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
	
	
	$Canvas/HUD.set_speed_text("%s\n%0.2f,%0.2f,%0.2f" % ["sprint" if is_sprint_enabled else "walk", self.velocity.x, self.velocity.y, self.velocity.z])
	
	# automatic step climb, ledge jump, and crouch; TO DO: can this also detect vault reliably? (we may need a forward pointing ray for that since railings are narrow)
	# TO DO: FIX: this needs to take into account the direction player *wants* to move, not just the direction they are moving as a result of move_and_slide: if player is already hard up against step, its velocity places the detector in direction of the sliding movement (which is parallel to the step) - we want to use direction of movement, but we need to offset the detector's position when player velocity and user movement direction don't match to check for a step in the user's desired direction
	var horizontal_direction = Vector3(self.velocity.x + user_direction.x, 0, self.velocity.z + user_direction.z).normalized()
	if horizontal_direction:
		forward_clearance.global_position = self.global_position + horizontal_direction * STEP_DETECTION_OFFSET
	
	if duck_detector.is_colliding():
		# TO DO: implement auto-duck; this reduces Player to 0.8-0.97 height (radius is unchanged) and reduces xz velocity to crawl speed
		$Canvas/HUD.set_movement_text("low ceiling ahead\n%s" % duck_detector.get_collider().get_parent().name)
		# TO DO: need to decide how to combine ducking and climbing into a 1m high duct 0.5m from floor; also, once in a duct, use HeadClearance to check if it's safe to stand up (this probably needs to be a ShapeCast cylinder/sphere while crouched so that player can't stand up until properly clear)
	
	# TO DO: how best to bridge gaps (e.g. from platform across purple pillars; player tends to stick on first gap)
	
	if step_detector.is_colliding():
		climb(user_direction)
	elif detected_step != null: # was climbing
		print("stop climbing ", detected_step.get_parent().name)
		stop_climbing()
		detected_step = null
	
	
	self.move_and_slide()
	
	
	
	return # temporary until last collision detection below is sorted out
	
	# TO DO: I think the purpose of this is last bit to bounce movable bodies off player (elastic collisions); every movable body is responsible for doing this (since any body can bounce off any other body), so move this logic into its own shared function if practical (that being said, we should also check if Godot physics can do this automatically for non-character bodies)
	for index in self.get_slide_collision_count():
		var collision = self.get_slide_collision(index)
		if collision.get_collider(0) is RigidBody3D: # what's best way to differentiate immovable vs movable bodies here? note that every mobile body is responsible for doing this
			if collision.get_collider(0) == feet_clearance.get_collider():
				return
			else:
				collision.get_collider(0).apply_central_impulse(
					(-collision.get_normal() * self.run_speed / collision.get_collider(0).mass) * delta)






func has_traction() -> bool:
	return is_on_floor() or climb_direction # player has traction while on ground/stairs/ladders/ledge-jump TO DO: see comment on is_far_from_floor about its reliability


func stop_climbing():
	$Canvas/HUD.set_movement_text("stop climbing")
	self.velocity.y = 0
	climb_direction = Vector3.ZERO
	#print("exiting step or ramp: ", detected_step.get_parent().name, "  ", self.velocity)


func climb(user_direction: Vector3) -> void: # user-direction is currently unused but see above comments on step detector's orientation
	var step = step_detector.get_collider()
	if step != detected_step: # found a new step so start climbing that
		detected_step = step
		print("detected climb ", detected_step.get_parent().name)
		
		if self.velocity.x != 0 or self.velocity.z != 0: # while player is moving # TO DO: this is crude;
			
			var col_point = step_detector.get_collision_point()
			var col_normal = step_detector.get_collision_normal()
			
			
			# TO DO: use collision point to determine if this is step, ledge, or too high to climb
			
			# TO DO: use normal to determine surface's slope (i.e. don't step up on steeply angled objects, unless they are ladders in which case climb); Q. what is steepest angled surface the player can reasonably step onto? maybe 15-30deg - TBD
			
			# TO DO: direction on xz plane matters; the detection ray should always be on leading edge of player body (currently it is fixed to front edge)
			#print("entering step or ramp: ", detected_step.get_parent().name, "  z=", self.velocity.z)
			
			var player_base_y = self.global_position.y - self.body.shape.height / 2
			
			var player_point = Vector3(self.global_position.x, player_base_y, self.global_position.z)
			
			var step_height = col_point.y - player_base_y
			
			if step_height <= MAX_STEP_HEIGHT:
				print("climb step ", step_height)
			elif step_height <= MAX_JUMP_HEIGHT:
				if is_sprint_enabled: # TO DO: we only want to jump if player is sprinting and user is pressing forward key; Q. should pressing forward + sidestep also be permitted? (jumping backwards is not)
					print("auto-jump ", step_height)
					y_speed = JUMP_Y_SPEED
					self.velocity.y = y_speed * 3
				else:
					print("can't auto-jump at walk")
				return
			else:
				print("too high")
				return
			

			# TO DO: if step height > MAX_STEP_HEIGHT it may be a jumpable ledge, in which case decide if/when to auto-jump (e.g. player must be running and not hard up against the ledge); we also want to prevent auto-jump auto-repeating - unlike stairs where player can step up repeatedly to next step, auto-jump should put player on ledge and stop waiting for new movement to start (alternatively, once on ledge start a ~1sec do_not_autojump timer so they can't immediately launch again onto next ledge - need to build test geometry to exercise this)
			
			#print(" pos=", self.global_position.y, "   h=", self.body.shape.height)
			#print(" player=%s  step=%s   height=%0.2f  normal=%s  vel=%s" % [player_point, col_point, step_height, col_normal, self.velocity])
			
			
			climb_direction = (col_point - player_point).normalized()
			climb_destination = col_point # TO DO: this probably isn't useful as player may turn/sidestep/be knocked sideways while climbing so is not guaranteed to end up at this point; also, it is the very edge of the stair; Q. can we rely on self.velocity.z<0 and StepDetection raycast for setting climb_direction back to ZERO when there is no more need to climb?
		
			#print("climb_direction=", climb_direction)
			
			$Canvas/HUD.set_movement_text("start climbing\n%s\n%s" % [detected_step.get_parent().name, climb_direction])
			
			var speed = -self.velocity.z
			self.velocity.y = speed * climb_direction.y * 2
			self.velocity.z *= -climb_direction.z
			
			#print("velocity=", self.velocity)
			
			#y_speed = step_height * 10 # kludge # TO DO: we want a nice straight climb
			#self.velocity.y = y_speed
		
	else: # still climbing same step
		#print("still climbing: ", self.velocity)
		if self.velocity.z < 0: # while player is moving forward
			var speed = -self.velocity.z
			self.velocity.y = speed * climb_direction.y * 2
		else:
			#y_speed = 0.0 # TO DO: appropriate?
			pass #print("stopped moving forward but still colliding with step") # TO DO: what, if anything, to do if player stops moving forward? will existing physics do the right thing?
			
			



func is_far_from_floor() -> bool:
	# @hhas01: TO DO: what is purpose of this? it is not the same as the built-in is_on_floor method
	# @810-Dude answers: There are some functions implemented to fix some quirks of the engine, like the function feet_clearance, that one exists due to that the function is_on_floor won't work unless move_and_slide is being called and the object moves. So certain static situations needed it. Perhaps now we don't, but it's something to consider
	return not feet_clearance.is_colliding()



# called by PickableItem when it detects Player walking into it

func found_item(item: PickableItem) -> void: # called by PickableItem when Player collides with it (we'll keep this flexible just in case we want any NPCs to grab items as well)
	# if there is space in inventory for this item, pick it up
	if Inventory.get_item(item.pickable).try_to_increment():
		item.picked_up()
		$Audio/PickedUp.play() # TO DO: we don't want to couple assets/audio directly to Player; need some sort of API between them



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



# external impulse, e.g. applied by a detonation's shrapnel radius or by firing rocket launcher

func add_impulse(impulse_in : Vector3) -> void:
	impulse += impulse_in




# TO DO: leaving these functions here for now; they came from previous weapon code but aiming is done by Player (although we do want to rotate projectiles that have 3D meshes so the projectile always points in direction of travel)
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
		main_camera.h_offset = randf_range(-shake_force, shake_force)
		main_camera.v_offset = randf_range(-shake_force, shake_force)
		shake_time -= _delta
	else:
		main_camera.h_offset = 0
		main_camera.v_offset = 0


#func _tilt(_delta : float) -> void: # don't think we want tilt though; it's getting too far away from Classic gameplay look and feel
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

