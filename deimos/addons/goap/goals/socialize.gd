extends GoapGoal

class_name SocializeGoal

func goap_get_class(): return "SocializeGoal"

# socialize will be available as long as there is another actor in the same room
func is_valid(_actor) -> bool:
	var socializable_actors = _actor.actor_state.get_local_elements("actors_team_"+str(_actor.team))
	if len(socializable_actors) == 0:
		return false
	#get random actor from the list
	var random_actor = socializable_actors[randi()%len(socializable_actors)]
	random_actor.actor_state.request_action("socialize", _actor)
	return true


# relax has lower priority compared to other goals
func priority(_actor) -> int:
	return 0
