tool
extends HBoxContainer
export(String) var Label_text = "Default control name" #setget update_title
var reading = false
var current_scancode = null

func update_labels():
	#Updates text from labels
	get_node("Button").text = OS.get_scancode_string(current_scancode)
	get_node("Confirm/CenterContainer/Label2").text = OS.get_scancode_string(current_scancode)
	

func update_title():
	$Label.text = Label_text

func _enter_tree():
	$Confirm.get_cancel().connect("pressed",self,"_on_Cancel") 
	#Get the popup cancel button and connect it to _on_cancel
	
	update_title()
	
	if InputMap.has_action(str(name)):
		current_scancode = InputMap.get_action_list(str(name))[0].scancode
		update_labels()
		#Get the first action asociated with this input
		get_node("Button").disabled = false
		

func _unhandled_input(event):
	if event is InputEventKey and reading:
		current_scancode = event.scancode
		get_node("Confirm/CenterContainer/Label2").text = OS.get_scancode_string(current_scancode)
		

func _on_change_control_pressed():
	#Opens the popup and starts reading from the keyboard
	$Confirm.popup_centered()
	reading = true



func _on_Popup_confirmed():
	var Event = InputEventKey.new()
	Event.scancode = current_scancode
	InputMap.action_erase_event (str(name), InputMap.get_action_list(str(name))[0])
	InputMap.action_add_event (str(name), Event)
	get_node("Button").text = OS.get_scancode_string(current_scancode)
	update_labels()
	reading = false


func _on_Confirm_popup_hide():
	reading = false
	#Stop reading keyboard input if the popup has closed
