extends Component

#Impulse: Adds an impulse to the player's movement based on the direction vector, 
# instead of the player's linear_velocity.
# We let the player use this ability twice

@export var impulse_strength: float : float = 7.0
@export var charge_time: float : float = 5
@export var charges_max: int : int = 2
var charges : int = 2
var movement_ref = null
var timer = null

func _ready():
	_component_name = "Impulse"
	setup_charge(charges_max)
	movement_ref = actor._get_component("movement")

func impulse() -> void:
	if charges > 0 and actor.direction.length() > 0: 
		actor.linear_velocity += actor.direction.normalized()*impulse_strength
		charges -= 1
		timer = get_tree().create_timer(charge_time)
		timer.connect("timeout",Callable(self,"add_charge"))
	
func _physics_process(delta) -> void:
	if enabled:
		_functional_routine(actor.input)

func _functional_routine(input: Dictionary)-> void:
	if get_key(input,"special"):
		impulse()

func add_charge():
	charges += 1
	if charges > charges_max:
		charges = charges_max
	emit_signal("charging_changed", charges)