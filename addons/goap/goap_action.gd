@tool
extends Node
class_name GOAPAction

@export var action: String = null : get = get_action, set = set_action
@export var preconditions: String = ""
@export var effect: String = ""
@export var cost: float = 1

func get_action():
	if action == null || action == "":
		return name
	else:
		return action

func set_action(a):
	action = a
