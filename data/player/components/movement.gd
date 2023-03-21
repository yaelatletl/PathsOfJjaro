extends Component
# All speed variables


@export var n_speed : float = 04 # Normal
@export var s_speed : float = 12 # Sprint
@export var w_speed : float = 08 # Walking
@export var c_speed : float = 10 # Crouch
@export var slide_on_crouch : bool = false
@export var can_wallrun : bool = false
# Physics variables
@export var gravity : float = 40 # Gravity force #45 is okay, don't change it 
@export var friction : float = 25 # friction

var DEFAULT_GRAVITY = gravity

@export var collision : NodePath = ""
@onready var col = get_node(collision)
@export var feet_path : NodePath = ""
@onready var feet = get_node(feet_path)
var _delta
var impulse = Vector3.ZERO



func _physics_process(delta : float) -> void:
	_delta = delta
	if enabled:
		_functional_routine(actor.input)

func _functional_routine(input : Dictionary) -> void:
	# Function for movement
	if _delta == null:
		return
	if enabled:
		_movement(input, _delta)
	
		# Function for crouch
		_crouch(input, _delta)
	

		# Function for sprint
		_sprint(input, _delta)

func _movement(input : Dictionary, _delta : float) -> void:
	actor.direction = Vector3()
	actor.direction += (-get_key(input, "left")    + get_key(input, "right")) * actor.head_basis.x
	actor.direction += (-get_key(input, "forward")  +  get_key(input, "back")) * actor.head_basis.z
	
	# Check is checked floor
	if actor.is_on_floor():
		actor.reset_wall_multi()
		actor.direction.y = 0 
		actor.direction = actor.direction.normalized()
		actor.direction = actor.direction.lerp(Vector3(), friction * _delta)
#		if get_key(input, "crouch"):
	else:
		
		# Applies gravity
		if (actor.is_on_wall() and actor.run_speed>12 and can_wallrun):
			actor.linear_velocity.y = lerp(actor.linear_velocity.y, 0.1, 10*_delta)
			actor.direction +=  (get_key(input, "forward") -get_key(input, "back"))*(-actor.wall_direction.cross(Vector3.UP) -actor.wall_direction)# * actor.head_basis.z)
			actor.direction = actor.direction.normalized()
		else:
			actor.linear_velocity.y -= gravity * _delta
	
	
	
	# Interpolates between the current position and the future position of the character
	actor.direction.normalized()
	var inertia = actor.linear_velocity.lerp(Vector3(), (0.75 * int(actor.is_on_floor()) + 1.25) *friction * _delta)
	if inertia.length() < 1:
		inertia = Vector3()
	var target = actor.direction * n_speed + inertia 
	actor.direction.y = 0
	var temp_velocity = actor.linear_velocity.lerp(target, n_speed * _delta)
	
	# Applies interpolation to the linear_velocity vector
	actor.linear_velocity.x = temp_velocity.x
	actor.linear_velocity.z = temp_velocity.z
	
	_impulse(_delta)
	
	# Calls the motion function by passing the linear_velocity vector
	actor.set_velocity(actor.linear_velocity)
	actor.set_up_direction(Vector3(0,1,0))
	actor.set_floor_stop_on_slope_enabled(false)
	actor.set_max_slides(4)
	actor.set_floor_max_angle(PI/4)
	# TODOConverter40 infinite_inertia were removed in Godot 4.0 - previous value `false`
	actor.move_and_slide()
	actor.linear_velocity = actor.velocity
	for index in actor.get_slide_collision_count():
		var collision = actor.get_slide_collision(index)
		if collision.get_collider(0) is RigidBody3D:
			if collision.get_collider(0) == actor.feet.get_collider():
				return
			else:
				collision.get_collider(0).apply_central_impulse((-collision.get_normal() * actor.run_speed/collision.get_collider(0).mass)*_delta)
	
func _crouch(input : Dictionary, _delta :float) -> void:
	# Inputs
	if not col:
		return
	
	# Get the character's head node
	
	# If the head node is not touching the ceiling
	if not actor.head.is_colliding():
		# Takes the character collision node
		
		# Get the character's collision shape
		var shape = col.shape.height
		
		# Changes the shape of the character's collision
		shape = lerp(shape, 1.7 - (get_key(input, "crouch") * 1.2), w_speed  * _delta)
		
		# Apply the new character collision shape
		col.shape.height = shape
		col.shape.radius = (0.24 - 0.12*get_key(input, "crouch"))
		feet.target_position.y = -shape
		



func _sprint(input : Dictionary, _delta : float) -> void:
	# Inputs
	# Make the character sprint
	if not get_key(input, "crouch"): # If you are not crouching
		# switch between sprint and walking
		actor.reset_slide_multi()
		var toggle_speed : float = w_speed + ((s_speed - w_speed) * get_key(input, "sprint")) #Normal Sprint Speed
		
		if actor.is_on_wall() and actor.is_far_from_floor() and actor.run_speed>12 and can_wallrun:
			toggle_speed *= actor.wall_multiplier #On wall sprint speed
			actor.wall_multiplier = lerp(actor.wall_multiplier, 1.0, _delta/20)
		# Create a character speed interpolation
		n_speed = lerp(n_speed, toggle_speed, 3 * _delta)
	else:
		# Create a character speed interpolation
		actor.linear_velocity.y -= 0.1*actor.run_speed*_delta
		if slide_on_crouch and actor.run_speed>12 and actor.is_on_floor():
			n_speed = lerp(n_speed, w_speed * actor.multiplier , 15* _delta)
			actor.multiplier = lerp(actor.multiplier, 0.8, _delta*20)
			return
		elif actor.is_on_floor():
			n_speed = lerp(n_speed, c_speed, actor.multiplier*_delta)
			actor.reset_slide_multi()
			actor.reset_wall_multi()

func _impulse(delta : float) -> void:
	if not is_zero_approx(abs(impulse.length())):
		actor.linear_velocity += impulse.lerp(Vector3.ZERO, delta) * delta
		impulse -= impulse.lerp(Vector3.ZERO, delta) * delta


func add_impulse(impulse_in : Vector3) -> void:
	impulse += impulse_in
