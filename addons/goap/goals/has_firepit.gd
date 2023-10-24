extends GoapGoal

class_name KeepFirepitBurningGoal

func goap_get_class(): return "KeepFirepitBurningGoal"


func is_valid(actor) -> bool:
	return actor.actor_state.get_elements("firepit").size() == 0


func priority(actor) -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {
		"has_firepit": true
	}
