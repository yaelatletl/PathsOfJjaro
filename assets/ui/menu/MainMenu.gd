extends Control
	
func _on_SinglePlayer_pressed():
	get_tree().change_scene("res://Recycling_plant.tscn")
	pass # Replace with function body.

func _on_HostNet_pressed():
	get_node("%MenuContents").current_tab = 1

func _on_JoinNetwork_pressed():
	get_node("%MenuContents").current_tab = 2
	pass # Replace with function body.

func _on_Settings_pressed():
	get_node("%MenuContents").current_tab = 3

func _on_Quit_pressed():
	get_tree().quit()


