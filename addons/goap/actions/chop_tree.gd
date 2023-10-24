extends GoapAction

class_name ChopTreeAction

func goap_get_class(): return "ChopTreeAction"


func is_valid(actor) -> bool:
	return actor.actor_state.get_elements("tree").size() > 0


func get_cost(actor, blackboard) -> int:
	if blackboard.has("position"):
		var closest_tree = actor.actor_state.find_closest_element("tree", blackboard)
		return int(closest_tree.position.distance_to(blackboard.position) / 7)
	return 3


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		"has_wood": true
	}


func perform(actor, delta) -> bool:
	var _closest_tree = actor.actor_state.find_closest_element("tree", actor)

	if _closest_tree:
		if _closest_tree.position.distance_to(actor.position) < 10:
				if actor.chop_tree(_closest_tree):
					actor.actor_state.set_state("has_wood", true)
					return true
				return false
		else:
			actor.move_to(actor.position.direction_to(_closest_tree.position), delta)

	return false
