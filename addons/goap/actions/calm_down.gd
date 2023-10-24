extends GoapAction

class_name CalmDownAction


func goap_get_class(): return "CalmDownAction"


func get_cost(_actor, _blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {
		"protected": true
	}


func get_effects() -> Dictionary:
	return {
		"is_frightened": false
	}


func perform(actor, _delta) -> bool:
	return actor.calm_down()
