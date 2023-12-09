extends GoapGoal

class_name EnemyKilledGoal

func goap_get_class(): return "EnemyKilledGoal"

func is_valid(actor) -> bool:
	return actor.actor_state.get_state("has_killed_enemy", false)


func priority(_actor) -> int:
	return 8


func get_desired_state() -> Dictionary:
	return {
		"has_killed_enemy": true
	}
