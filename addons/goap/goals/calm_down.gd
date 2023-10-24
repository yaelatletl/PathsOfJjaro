extends GoapGoal

class_name CalmDownGoal

func goap_get_class(): return "CalmDownGoal"

func is_valid(actor) -> bool:
	return actor.actor_state.get_state("is_frightened", false)


func priority(_actor) -> int:
	return 10


func get_desired_state() -> Dictionary:
	return {
		"is_frightened": false
	}
