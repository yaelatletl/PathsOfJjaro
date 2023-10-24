extends Node
class_name ActorState

#This script should be used so the world can be described to the NPCs

var _state = {
}
var target = null
var objects_im_aware_of : Dictionary = {}

func register_object(object, location):
	objects_im_aware_of[object] = location

func get_state(state_name, default = null):
	return _state.get(state_name, default)


func set_state(state_name, value):
	_state[state_name] = value

func set_target(_target):
	target = _target

func clear_state():
	_state = {}


func get_elements(group_name):
	return self.get_tree().get_nodes_in_group(group_name) #We may still want to be able to get elements that the actor is not aware of

func get_local_elements(group_name):
	var global_elements = get_elements(group_name)
	var local_elements = []
	for element in global_elements:
		if element in objects_im_aware_of: 
			local_elements.append(element)
	return local_elements

#This function returns the closest object of a group that the actor is aware of
func find_closest_object(group_name, actor):
	var local_elements = get_local_elements(group_name)
	var closest_element = null
	for element in local_elements:
		if closest_element == null:
			closest_element = element
		else:
			if actor.global_transform.origin.distance_to(element.global_transform.origin) < actor.global_transform.origin.distance_to(closest_element.global_transform.origin):
				closest_element = element
	return closest_element

signal action_requested(requester)

func request_action(name, requester = null):
	var action_request = {
		"name" : name,
		"target" : requester
	}
	emit_signal("action_requested", action_request, requester)

func console_message(object):
	var console = get_tree().get_nodes_in_group("console")[0] as TextEdit
	console.text += "\n%s" % str(object)
	console.set_caret_line(console.get_line_count())

var latest_message = {
	"sender" : null,
	"message_type" : null,
	"location" : null
}
var latest_message_time = 0
# enum MESSAGE_TYPE{
# 	ENEMY_ON_SIGHT,
# 	ENEMY_LOST_LAST_SEEN,
# 	OBJECTIVE_COMPLETED,
# 	OBJECTIVE_FAILED,
# 	INVESTIGATE_LOCATION,
# 	ALLY_BODY_FOUND,
# 	ENEMY_BODY_FOUND,
# 	REINFORCEMENTS_REQUESTED,
# 	REINFORCEMENTS_APPROVED,
# 	REINFORCEMENTS_DENIED,
# 	ENEMY_KILLED,
# 	ALLY_KILLED,
# 	REQUEST_NEW_OBJECTIVE,
# 	CALL_FOR_HELP,
# 	HELP_REQUEST_APPROVED,
# 	CANNOT_COMPLY
# }
#MESSAGE STRUCTURE
#{
#	"sender" : sender,
#	"message_type" : message_type, 
#	"location" : location
#}
func _on_message_received(message):
	latest_message = message
	#latest_message_time = OS.delay_msec()  #TODO: Check how to reimplement this
	# console_message("Message received: %s" % str(message))
	# console_message("Message type: %s" % str(message["message_type"]))
	# console_message("Message sender: %s" % str(message["sender"]))
	# console_message("Message location: %s" % str(message["location"]))

