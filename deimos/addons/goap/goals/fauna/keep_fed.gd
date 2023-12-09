extends GoapGoal

class_name KeepFedGoal

func goap_get_class(): return "KeepFedGoal"

# This is not a valid goal when hunger is less than 50.
func is_valid(actor) -> bool:
	return actor.actor_state.get_state("hunger", 0)  > 50 and actor.actor_state.get_elements("food").size() > 0


func priority(actor) -> int:
	return 1 if actor.actor_state.get_state("hunger", 0) < 75 else 2


func get_desired_state() -> Dictionary:
	return {
		"is_hungry": false
	}
