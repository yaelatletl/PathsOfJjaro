extends Component

#Class that converts information to input values. 
var navigator : NavigationAgent3D = null
var movement : Node = null
var planner : Node = null

var navigator_planned_position : Vector3 = Vector3()

@export var jump_treshold: float : float = 1.0

func _ready() -> void:
	navigator = actor._get_component("navigation")
	movement = actor._get_component("movement_basic")
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

func _physics_process(delta):
	navigator_planned_position = navigator.get_next_location()

func get_input():
	#We have to determine what inputs allow us to get to the desired position, even if were not looking at it. 
	var head_basis = actor.head.global_transform.basis
	var our_direction = actor.global_transform.origin - navigator_planned_position
	var direction =  head_basis * our_direction
	if direction.z > 0:
		actor.input["forward"] = 1
	if direction.z < 0:
		actor.input["back"] = 1
	if direction.x > 0:
		actor.input["left"] = 1
	if direction.x < 0:
		actor.input["right"] = 1
	if direction.y > jump_treshold:
		actor.input["jump"] = 1
