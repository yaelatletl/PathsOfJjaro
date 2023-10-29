extends Component

@export var jump_height: float  : float = 15 # Jump height
var movement = null
var jump_timer = null
var can_shift = true

func _ready():
	movement = actor._get_component("movement")





func _toggle_shift():
	can_shift = false
	if jump_timer == null:
		jump_timer = get_tree().create_timer(0.2)
		jump_timer.connect("timeout",Callable(self,"_enable_jump"))

func _physics_process(_delta):
	if enabled:
		_shift(_delta)
	
func _enable_shift():
	can_shift = true
	jump_timer = null
	
func _shift(_delta) -> void:
	# Makes the player jump if he is checked the ground
	if actor.input["jump"] and can_shift:
		_toggle_shift()
		actor.reset_wall_multi()
		if not actor.test_move(actor.transform, actor.direction+Vector3(0,1,0)):
			actor.position += actor.direction+Vector3(0,1,0)
			