extends KinematicBody

const SLIDE_MULT = 3
const WALLRUN_MULT = 1.7

export(float) var mass = 45

# All vectors
var linear_velocity : = Vector3() # linear_velocity vector
var direction    : = Vector3() # Direction Vector
var acceleration : = Vector3() # Acceleration Vector
var head_basis : Basis
# All character inputs

remotesync var input : Dictionary = {}
signal died()
signal health_changed(health, shields)

#Wall running and shared variables
remotesync var health = 100
remotesync var shields = 100
var wall_direction : Vector3 = Vector3.ZERO
var wall_normal 
var run_speed : float = 0.0
var wall_multiplier : float = 1.5
var multiplier : float = 1.5

var components : Dictionary = {}
var angle 
onready var head = $head
onready var feet = $feet

func _get_component(_name:String) -> Node:
	if components.has(_name):
		return components.get(_name)
	else:
		return null


func _register_component(_name : String, _component_self : Node) -> void:
	if components.has(_name):
		printerr("The Actor ", self, " already has a component ", _name)
	else:
		components[_name] = _component_self

func _physics_process(delta):
	head_basis = head.global_transform.basis
	if is_on_wall():
		wall_normal = get_slide_collision(0)
		#yield(get_tree().create_timer(0.2), "timeout")
		wall_direction = wall_normal.normal
	run_speed = Vector2(linear_velocity.x, linear_velocity.z).length()


		
func reset_wall_multi():
	wall_multiplier = WALLRUN_MULT

func reset_slide_multi():
	multiplier = SLIDE_MULT

	
func is_far_from_floor() -> bool:
	if feet.is_colliding():
		return false
	return true

remotesync func _damage(amount : float, type):
	var temp = amount
	amount = (amount - shields)/10
	shields -= temp	
	if health > 0:
		health -= amount
	if health <= 0:
		die()
	emit_signal("health_changed", health, shields)
	Gamestate.set_in_all_clients(self, "health", health)
	Gamestate.set_in_all_clients(self, "shields", shields)
		
remotesync func die():
	Gamestate.call_on_all_clients(self, "die", null)
	_get_component("input").enabled = false
	emit_signal("died")
	print("Player "+name+" died")

func request_interact(interactable : Spatial, message : String, time : float = 0.0):
	#We need to pass the message to the HUD
	if	_get_component("interactor"):
		_get_component("interactor").request_interact(interactable, message, time)

func stop_interact():
	if _get_component("interactor"):
		_get_component("interactor").stop_interact()
