extends Component

#Stimulant: Increases linear_velocity by "velocity_constant" per phys frame during "stim_duration" 
#numbers above 1.1 get easily out of hand, use with care. 

#TODO -  refactor for the recharging system


var active : bool = false
@export var velocity_constant: float  = 0.8
@export var stim_duration: float  = 5

var timer = null
func _ready():
	_component_name = "Stimulant"
	setup_charge(stim_duration)

func toggle_stim(turn_off = false) -> void:
	if not active:
		active = true
		timer = get_tree().create_timer(stim_duration)
		timer.connect("timeout",Callable(self,"toggle_stim").bind(true))
	if turn_off:
		active = false

func _physics_process(delta) -> void:
	if enabled:
		_functional_routine(actor.input)
		if timer != null:
			emit_signal("charging_changed", timer.time_left)
func _functional_routine(input: Dictionary)-> void:
	if get_key(input,"special"):
		toggle_stim()
		
	if active:
		actor.linear_velocity += actor.linear_velocity.normalized()*Vector3(1,0,1)*velocity_constant
