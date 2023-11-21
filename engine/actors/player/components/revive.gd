extends Component


# what does this do? why is it in a separate script?


@export var can_self_res: bool = false
@export var revive_time: float = 5.0
var knocked = false
@export var enable_exeptions: Array = []
@export var collision : NodePath = ""

var original_height = 0.0
var original_width = 0.0

@onready var col = get_node(collision)

func _ready():
	connect("body_entered",Callable(self,"_on_body_entered"))
	connect("body_exited",Callable(self,"_on_body_exited"))
	original_height = col.shape.height
	original_width = col.shape.radius
	actor.connect("died",Callable(self,"_on_died"))

func _on_body_entered(body):
	if (actor == body and not can_self_res) or not knocked:
		return
	else:
		if body.has_method("_get_component"):
			var inter = body._get_component("interactor")
			if inter != null:
				inter.request_interact(self, "Press E to revive", revive_time)

func _on_body_exited(body):
	if body.has_method("_get_component"):
		var inter = body._get_component("interactor")
		if inter != null:
			inter.clear_interact()
	
func _on_died():
	knocked = true
	_on_body_entered(actor)

func interaction_triggered(interactor_body : Node3D):
	if knocked:
		revive()
		knocked = false
		return true
	else:
		return false

func revive():
	if can_self_res:
		var inter = actor._get_component("interactor")
		if inter != null:
			inter.clear_interact()
	for component in actor.components:
		if component in enable_exeptions:
			actor._get_component(component).enabled = false
		else:
			actor._get_component(component).enabled = true
	actor.health = 100
	col.shape.height = original_height
	col.shape.radius = original_width
	actor.emit_signal("health_changed", actor.health, actor.shields)
	enabled = false
