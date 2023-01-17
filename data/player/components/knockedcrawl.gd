extends Component

# All speed variables

export(float) var n_speed : float = 0.1 # Normal
export(float) var w_speed : float = 0.2 # Walking
export(bool) var can_move : bool = false
export(float) var knocked_height : float = 0.1
# Physics variables
export(float) var gravity      : float = 45 # Gravity force #45 is okay, don't change it 
export(float) var friction     : float = 25 # friction
export(Array) var disable_exeptions = []

export(NodePath) var collision : NodePath = ""
onready var col = get_node(collision)

func _ready():
	if enabled:
		enabled = false
		._ready()
		_component_name = "knocked_down_crawl"
		actor.connect("died", self, "_on_actor_died")

func _on_actor_died():
	for component in actor.components:
		if component in disable_exeptions:
			continue
		else:
			actor._get_component(component).enabled = false
	col.shape.height = knocked_height
	col.shape.radius = knocked_height
	enabled = true

func _physics_process(delta):
	if enabled:
		_movement(actor.input, delta)

func _movement(input : Dictionary, _delta : float) -> void:
	actor.direction = Vector3()
	if can_move:
		actor.direction += (-get_key(input, "left")    + get_key(input, "right")) * actor.head_basis.x
		actor.direction += (-get_key(input, "forward")  +  get_key(input, "back")) * actor.head_basis.z
	
	# Check is on floor
	if actor.is_on_floor():
		actor.direction.y = 0 
		actor.direction = actor.direction.normalized()
		actor.direction = actor.direction.linear_interpolate(Vector3(), friction * _delta)
#		if get_key(input, "crouch"):
	else:
		# Applies gravity
		actor.linear_velocity.y += -gravity * _delta
	
	# Interpolates between the current position and the future position of the character
	actor.direction.normalized()
	var inertia = actor.linear_velocity.linear_interpolate(Vector3(), (0.75 * int(actor.is_on_floor()) + 1.25) *friction * _delta)
	if inertia.length() < 1:
		inertia = Vector3()
	var target = actor.direction * n_speed + inertia 
	actor.direction.y = 0
	var temp_velocity = actor.linear_velocity.linear_interpolate(target, n_speed * _delta)
	
	# Applies interpolation to the linear_velocity vector
	actor.linear_velocity.x = temp_velocity.x
	actor.linear_velocity.z = temp_velocity.z
	
	# Calls the motion function by passing the linear_velocity vector
	actor.linear_velocity = actor.move_and_slide(actor.linear_velocity, Vector3(0,1,0), false, 4, PI/4, false)
	
	for index in actor.get_slide_count():
		var collision = actor.get_slide_collision(index)
		if collision.collider is RigidBody:
				collision.collider.apply_central_impulse(-collision.normal * actor.run_speed/collision.collider.mass)
