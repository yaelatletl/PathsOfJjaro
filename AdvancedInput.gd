extends Component
@export var run_is_toggle: bool : bool = true
@export var crouch_is_toggle: bool : bool = true

@export var captured: bool : bool = true # Does not let the mouse leave the screen

var can_jump = true
var jump_timer = null
var input_devices : Dictionary = {}
var local_input : Dictionary = {}
func _ready():
	#Input.set_use_accumulated_input(false)
	Input.connect("joy_connection_changed",Callable(self,"_on_joy_changed"))

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
	
	local_input["look_y"] = 0
	local_input["look_x"] = 0
	local_input["special"] = 0
	local_input["left"]   = 0
	local_input["right"]  = 0
	local_input["forward"] = 0
	local_input["back"]   = 0
	local_input["jump"] = 0
	local_input["extra_jump"] = 0
	local_input["use"] = 0
	local_input["crouch"] = 0
	local_input["sprint"] = 0
	local_input["next_weapon"] = 0
	local_input["shoot"] = 0
	local_input["reload"] = 0
	local_input["zoom"] = 0

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
		if not mpAPI.is_server() or not enabled:
			return
		else:
			get_input()
			get_tree().create_timer(0.01).connect("timeout",Callable(self,"functional_routine"))
	else:
		get_input()
		get_tree().create_timer(0.01).connect("timeout",Callable(self,"functional_routine"))

		
func get_input():
	actor.input["left"]   = local_input["left"]
	actor.input["right"]  = local_input["right"]
	actor.input["forward"] = local_input["forward"]
	actor.input["back"]   = local_input["back"]
	actor.input["next_weapon"] = local_input["next_weapon"]

	if not crouch_is_toggle:
		actor.input["crouch"] = local_input["crouch"]
	if not run_is_toggle:
		actor.input["sprint"] = local_input["sprint"]
	actor.input["use"] = local_input["use"]
	actor.input["shoot"] = local_input["shoot"]
	actor.input["reload"] = local_input["reload"]
	actor.input["zoom"] = local_input["zoom"]
	actor.input["special"] = local_input["special"]
	actor.input["extra_jump"] = local_input["extra_jump"]
	actor.input["look_y"] = local_input["look_y"]
	actor.input["look_x"] = local_input["look_x"]
	sync_input()


func sync_input():
	if get_tree().has_multiplayer_peer():
		if mpAPI.is_server() and not get_tree().is_server(): 
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
		if not mpAPI.is_server() or not enabled:
			return
		else:
			unhandled(event)
	else:
		unhandled(event)

func unhandled(event):
	# Calls function to switch between locked and unlocked mouse
	_mouse_toggle()
	
	if int(Input.is_action_just_pressed("KEY_SPACE")):
		actor.input["jump"] = true
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
#		if mpAPI.is_server() and not get_tree().is_server(): 
			#Gamestate.set_in_all_clients(self,"input", actor.input)
#			actor.rset_unreliable_id(1, "input", actor.input)

#	if Input.is_action_just_released(("KEY_SPACE")) and Input.is_action_pressed("KEY_SPACE"):
#		actor.input["jump_extra"] = 1


	
func _on_joy_changed(device : int):
	input_devices[device]["player"]

# Deletes a subdictionary when the corresponding device is disconnected
func _on_joy_disconnected(device : int):
	input_devices.erase(device)



func _input(event):
	if input_devices.has(event.device):
		pass
	else:
		input_devices[event.device] = {}
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if Input.get_joy_name(event.device) == "XInput Gamepad":
			_XInput_scheme(event)
			

func _XInput_scheme(event):
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_0: 
			if event.axis_value > 0:
				input_devices[event.device]["right"] = clamp(event.axis_value, 0, 1)
			else:
				input_devices[event.device]["left"] = clamp(-event.axis_value, 0, 1)
	
		if event.axis == JOY_AXIS_1:
			if event.axis_value > 0:
				input_devices[event.device]["back"] = clamp(event.axis_value, 0, 1)
			else:
				input_devices[event.device]["forward"] = clamp(-event.axis_value, 0, 1)
	
		if event.axis == JOY_AXIS_2:
			input_devices[event.device]["look_x"] = event.axis_value

		if event.axis == JOY_AXIS_3:
			input_devices[event.device]["look_y"] = event.axis_value
		
		if event.axis == JOY_AXIS_6:
			input_devices[event.device]["shoot"] = event.axis_value
		if event.axis == JOY_AXIS_7:
			input_devices[event.device]["zoom"] = event.axis_value
