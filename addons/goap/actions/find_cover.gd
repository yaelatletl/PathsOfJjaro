extends GoapAction

class_name FindCoverAction


func goap_get_class(): return "FindCoverAction"


func get_cost(_actor, _blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		"near_cover": true
	}


func perform(actor, delta) -> bool:
	var closest_cover = actor.actor_state.find_closest_element("cover", actor)

	if closest_cover == null:
		return false

	if closest_cover.global_transform.origin.distance_to(actor.global_transform.origin) < 1:
		return true

	actor.set_target(closest_cover.global_transform.origin)
	return false
