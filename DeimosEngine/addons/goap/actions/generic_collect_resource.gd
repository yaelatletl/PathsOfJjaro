extends GoapAction

class_name GenericCollectResourceAction

var element = "wood_stock"
var state = "has_wood"
func goap_get_class(): return "GenericCollectResourceAction"


func is_valid(actor) -> bool:
	return actor.actor_state.get_elements(element).size() > 0


func get_cost(actor, blackboard) -> int:
	if blackboard.has("position"):
		var closest_tree = actor.actor_state.find_closest_element(element, blackboard)
		return int(closest_tree.position.distance_to(blackboard.position) / 5)
	return 5


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		state: true,
	}


func perform(actor, delta) -> bool:
	var closest_stock = actor.actor_state.find_closest_element(element, actor)

	if closest_stock:
		if closest_stock.position.distance_to(actor.position) < 10:
			closest_stock.queue_free()
			actor.actor_state.set_state(state, true)
			return true
		else:
			actor.move_to(actor.position.direction_to(closest_stock.position), delta)

	return false
