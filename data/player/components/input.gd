extends Component
@export var run_is_toggle: bool : bool = false
@export var crouch_is_toggle: bool : bool = false

@export var captured: bool : bool = true # Does not let the mouse leave the screen

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
	actor.input["shoot"] = int(Input.is_action_pressed("mb_left"))
	actor.input["reload"] = int(Input.is_action_pressed("KEY_R"))
	actor.input["zoom"] = int(Input.is_action_pressed("mb_right"))
	get_tree().create_timer(0.01).connect("timeout",Callable(self,"functional_routine"))



func _mouse_toggle() -> void:
	# Function to lock or unlock the mouse in the center of the screen
	if Input.is_action_just_pressed("KEY_ESCAPE"):
		# Captured will receive the opposite of the value itself
		captured = !captured
	
	if captured:
		# Locks the mouse in the center of the screen
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# Unlocks the mouse from the center of the screen
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func functional_routine():
	if get_tree().has_multiplayer_peer():
		if not is_multiplayer_authority() or not enabled:
			return
		else:
			get_input()
			get_tree().create_timer(0.01).connect("timeout",Callable(self,"functional_routine"))
	else:
		get_input()
		get_tree().create_timer(0.01).connect("timeout",Callable(self,"functional_routine"))

		
func get_input():
	actor.input["left"]   = int(Input.is_action_pressed("KEY_A"))
	actor.input["right"]  = int(Input.is_action_pressed("KEY_D"))
	actor.input["forward"] = int(Input.is_action_pressed("KEY_W"))
	actor.input["back"]   = int(Input.is_action_pressed("KEY_S"))
	actor.input["next_weapon"] = int(Input.is_action_pressed("NEXT_GUN"))
	if not crouch_is_toggle:
		actor.input["crouch"] = int(Input.is_action_pressed("KEY_CTRL"))
	if not run_is_toggle:
		actor.input["sprint"] = int(Input.is_action_pressed("KEY_SHIFT"))
	actor.input["use"] = int(Input.is_action_pressed("USE"))
	actor.input["shoot"] = int(Input.is_action_pressed("mb_left"))
	actor.input["reload"] = int(Input.is_action_pressed("KEY_R"))
	actor.input["zoom"] = int(Input.is_action_pressed("mb_right"))
	actor.input["special"] = int(Input.is_action_just_pressed("SPECIAL"))
	actor.input["extra_jump"] = int(Input.is_action_pressed("KEY_SPACE"))
	actor.input["use"] = int(Input.is_action_pressed("USE"))
	sync_input()
	#if get_tree().has_multiplayer_peer():
	#	if is_multiplayer_authority() and not get_tree().is_server(): 
			#Gamestate.set_in_all_clients(self,"input", actor.input)
	#		actor.rset_unreliable_id(1, "input", actor.input)
#		actor.input["look_y"] = 0
#		actor.input["look_x"] = 0
#Let's sync the input each 10 ms, for that, we will create a pseudo-thread


func sync_input():
	if get_tree().has_multiplayer_peer():
		if is_multiplayer_authority() and not get_tree().is_server(): 
			actor.rset_unreliable_id(1, "input", actor.input)
			Gamestate.set_in_all_clients(actor, "input", actor.input)


func mouse_move(event):
	Input.get_last_mouse_velocity()
	if event is InputEventMouseMotion:
		actor.input["look_y"] = event.relative.y 
		actor.input["look_x"] = event.relative.x 
		await get_tree().create_timer(0.001).timeout # Replace timer with a tenth of a frame quantum (From new singleton)
		actor.input["look_y"] = 0
		actor.input["look_x"] = 0


func _unhandled_input(event):
	if get_tree().has_multiplayer_peer():
		if not is_multiplayer_authority() or not enabled:
			return
		else:
			unhandled(event)
	else:
		unhandled(event)

func unhandled(event):
	# Calls function to switch between locked and unlocked mouse
	_mouse_toggle()
	
	actor.input["jump"] = int(Input.is_action_just_pressed("KEY_SPACE"))
	mouse_move(event)
	

	if run_is_toggle:
		if Input.is_action_just_pressed("KEY_SHIFT"):
			actor.input["sprint"] = int(not bool(actor.input["sprint"]))
		if Input.is_action_pressed("KEY_CTRL") or actor.run_speed < 0.3 or Input.is_action_just_released("KEY_W"):
			actor.input["sprint"] = 0
	if crouch_is_toggle:
		if Input.is_action_just_released("KEY_CTRL"):
			actor.input["crouch"] = int(not bool(actor.input["crouch"]))
		if Input.is_action_pressed("KEY_SHIFT") or Input.is_action_just_released("KEY_SPACE"):
			actor.input["crouch"] = 0
#	if get_tree().has_multiplayer_peer():
#		if is_multiplayer_authority() and not get_tree().is_server(): 
			#Gamestate.set_in_all_clients(self,"input", actor.input)
#			actor.rset_unreliable_id(1, "input", actor.input)

#	if Input.is_action_just_released(("KEY_SPACE")) and Input.is_action_pressed("KEY_SPACE"):
#		actor.input["jump_extra"] = 1
