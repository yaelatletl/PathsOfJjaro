extends Component

var jump_timer = null
var can_jump = true

export(float) var jump_height  : float = 15 # Jump height
export(bool) var jumps_from_wall : bool = false

var movement = null
func _ready():
	movement = actor._get_component("movement_basic")


func _toggle_jump():
	can_jump = false
	yield(get_tree().create_timer(0.05), "timeout")
	can_jump = true

func _physics_process(_delta):
		# Function for jump
	if movement != null:
		if actor.is_on_floor() or actor.is_on_wall():
			movement.gravity = movement.DEFAULT_GRAVITY
		else:
			movement.gravity = lerp(movement.gravity, movement.DEFAULT_GRAVITY, _delta * 10)
	if not enabled:
		return
	if enabled:
		_jump(_delta)

	
func _jump(_delta) -> void:
	var check_jump = (not actor.is_far_from_floor()) or (jumps_from_wall and actor.is_on_wall())
	# Makes the player jump if he is on the ground
	if actor.input["jump"] and can_jump and check_jump:
		_toggle_jump()
		actor.reset_wall_multi()
		actor.input["jump"] = 0 #Consumes the input
		if not actor.is_far_from_floor():
			actor.linear_velocity.y += jump_height
		elif actor.is_on_wall() and jumps_from_wall:
			actor.linear_velocity.y += jump_height
			if movement != null:
				movement.gravity /= 5.0
			actor.linear_velocity +=  actor.head_basis.x * jump_height*1.2
		
