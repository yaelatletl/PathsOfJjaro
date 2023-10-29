extends Component
var fuel = 150
@export var fuel_limit: float = 150
@export var depleation_rate: float = 1
@export var refill_rate: float = .75

func _ready():
	setup_charge(fuel_limit)

func _physics_process(delta):
	if not enabled:
		return
	if actor.input["extra_jump"] and not (not actor.is_far_from_floor() or actor.is_on_wall()) and fuel > 0:
		actor.linear_velocity.y = lerp(actor.linear_velocity.y, 10, 100*delta)
		fuel -= depleation_rate
	elif fuel <= fuel_limit and (not actor.is_far_from_floor() or actor.is_on_wall()): 
		fuel += refill_rate
	emit_signal("charging_changed", fuel)
