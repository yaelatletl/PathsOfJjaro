extends GoapGoal

class_name RelaxGoal

func goap_get_class(): return "RelaxGoal"

# relax will always be available
func is_valid(_actor) -> bool:
	return true


# relax has lower priority compared to other goals
func priority(_actor) -> int:
	return 0
