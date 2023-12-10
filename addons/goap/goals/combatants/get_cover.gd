extends GoapGoal

class_name GetCoverGoal
func goap_get_class(): return "GetCoverGoal"

func is_valid(actor) -> bool:
	return actor.actor_state.get_state("has_cover", false)


func priority(_actor) -> int:
	return 8


func get_desired_state() -> Dictionary:
	return {
		"has_cover": true
	}
