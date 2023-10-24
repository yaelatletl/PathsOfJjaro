#
# This script integrates the actor (NPC) with goap.
# In your implementation you could have this logic
# inside your NPC script.
#
# As good practice, I suggest leaving it isolated like
# this, so it makes re-use easy and it doesn't get tied
# to unrelated implementation details (movement, collisions, etc)
extends Node

class_name GoapAgent

var _goals
var _current_goal
var _current_plan
var _current_plan_step = 0

@onready var actor = get_parent() # Parent should be AI_Input
#
# On every loop this script checks if the current goal is still
# the highest priority. if it's not, it requests the action planner a new plan
# for the new high priority goal.
#
@onready var action_planner = GoapActionPlanner.new()

func _ready():
	action_planner.set_actions([
		BuildFirepitAction.new(),
		ChopTreeAction.new(),
		GenericCollectResourceAction.new(), # This needs to be overriden by the specific resource
		CalmDownAction.new(),
		FindCoverAction.new(),
		FindFoodAction.new(),
	])



func _process(delta):
	var goal = _get_best_goal()
	if _current_goal == null or goal != _current_goal:
	# You can set in the blackboard any relevant information you want to use
	# when calculating action costs and status. I'm not sure here is the best
	# place to leave it, but I kept here to keep things simple.
		var blackboard = {
			"position": actor.actor.global_transform.origin,
			}

		for s in actor.actor_state._state:
			blackboard[s] = actor.actor_state._state[s]

		_current_goal = goal
		_current_plan = action_planner.get_plan(actor, _current_goal, blackboard)
		_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)


func _init(actor, goals: Array):
	actor = actor
	_goals = goals


#
# Returns the highest priority goal available.
#
func _get_best_goal():
	var highest_priority

	for goal in _goals:
		if goal.is_valid(actor) and (highest_priority == null or goal.priority(actor) > highest_priority.priority(actor)):
			highest_priority = goal

	return highest_priority


#
# Executes plan. This function is called on every game loop.
# "plan" is the current list of actions, and delta is the time since last loop.
#
# Every action exposes a function called perform, which will return true when
# the job is complete, so the agent can jump to the next action in the list.
#
func _follow_plan(plan, delta):
	if plan.size() == 0:
		return

	var is_step_complete = plan[_current_plan_step].perform(actor, delta)
	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1
