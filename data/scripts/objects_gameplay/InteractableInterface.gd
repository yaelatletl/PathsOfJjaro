extends InteractableGeneric
class_name InteractableInterface

export(float) var cooldown = 0.0
var can_interact = true

signal interacted_successfully(body)

func toggle_interact():
	can_interact = true

func interaction_triggered(interacting_body : Spatial):
	
	if can_interact:
		emit_signal("interacted_successfully", interacting_body)
	if interacting_body.has_method("_get_component"):
		can_interact = false
		get_tree().create_timer(cooldown).connect("timeout", self, "toggle_interact")
		interacting_body.input["use"] = 0 #Consume the input
	pass

