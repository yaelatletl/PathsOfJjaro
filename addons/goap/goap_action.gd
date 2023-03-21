@tool
extends Node
class_name GOAPAction

@export var action: String = "" :
	get:
		return get_action()
	set(a):
		set_action(a)
		
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
