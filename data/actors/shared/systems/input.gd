extends Component
@export var run_is_toggle : bool = false
@export var crouch_is_toggle : bool = false

@export var captured : bool = true # Does not let the mouse leave the screen

var can_jump = true
var jump_timer = null


func _ready():
	#Input.set_use_accumulated_input(false)
	_component_name = "input"
	actor.input["look_y"] = 0
	actor.input["look_x"] = 0
	actor.input["special"] = 0
	actor.input["left"]   = 0
	actor.input["right"]  = 0
	actor.input["forward"] = 0
	actor.input["back"]   = 0
	actor.input["jump"] = 0
	actor.input["extra_jump"] = 0
	actor.input["use"] = 0
	actor.input["crouch"] = 0
	actor.input["sprint"] = 0
	actor.input["next_weapon"] = 0
	actor.input["shoot"] = 0
	actor.input["reload"] = 0
	actor.input["zoom"] = 0
	get_tree().create_timer(0.01).connect("timeout",Callable(self,"functional_routine"))


func _mouse_toggle() -> void:
	# Function to lock or unlock the mouse in the center of the screen
	if Input.is_action_just_pressed("ESCAPE"):
		# Captured will receive the opposite of the value itself
		captured = !captured
	
	if captured:
		# Locks the mouse in the center of the screen
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# Unlocks the mouse from the center of the screen
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func functional_routine():
		get_input()
		get_tree().create_timer(0.01).connect("timeout",Callable(self,"functional_routine"))

		
func get_input():
	
	actor.input["left"]   = int(Input.is_action_pressed("MOVE_LEFT"))
	actor.input["right"]  = int(Input.is_action_pressed("MOVE_RIGHT"))
	actor.input["forward"] = int(Input.is_action_pressed("MOVE_FORWARD"))
	actor.input["back"]   = int(Input.is_action_pressed("MOVE_BACKWARD"))
	actor.input["next_weapon"] = int(Input.is_action_pressed("NEXT_GUN"))
#	if not crouch_is_toggle:
#		actor.input["crouch"] = int(Input.is_action_pressed("CROUCH"))
	if not run_is_toggle:
		actor.input["sprint"] = int(Input.is_action_pressed("SPRINT"))
	actor.input["use"] = int(Input.is_action_pressed("USE"))
	actor.input["shoot"] = int(Input.is_action_pressed("SHOOT"))
	actor.input["reload"] = int(Input.is_action_pressed("RELOAD"))
	actor.input["zoom"] = int(Input.is_action_pressed("ZOOM"))
	actor.input["special"] = int(Input.is_action_just_pressed("SPECIAL"))
	actor.input["extra_jump"] = int(Input.is_action_pressed("JUMP"))


func mouse_move(event):
	Input.get_last_mouse_velocity()
	if event is InputEventMouseMotion:
		actor.input["look_y"] = event.relative.y 
		actor.input["look_x"] = event.relative.x 
		await get_tree().create_timer(0.001).timeout # Replace timer with a tenth of a frame quantum (From new singleton)
		actor.input["look_y"] = 0
		actor.input["look_x"] = 0

func _unhandled_input(event):
	unhandled(event)

func unhandled(event):
	# Calls function to switch between locked and unlocked mouse
	_mouse_toggle()
	
	actor.input["jump"] = int(Input.is_action_just_pressed("JUMP"))
	mouse_move(event)
	

	if run_is_toggle:
		if Input.is_action_just_pressed("SPRINT"):
			actor.input["sprint"] = int(not bool(actor.input["sprint"]))
		if Input.is_action_pressed("CROUCH") or actor.run_speed < 0.3 or Input.is_action_just_released("MOVE_FORWARD"):
			actor.input["sprint"] = 0
	if crouch_is_toggle:
		if Input.is_action_just_released("CROUCH"):
			actor.input["crouch"] = int(not bool(actor.input["crouch"]))
		if Input.is_action_pressed("SPRINT") or Input.is_action_just_released("JUMP"):
			actor.input["crouch"] = 0
