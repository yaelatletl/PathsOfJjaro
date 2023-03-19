extends Control
	
func _on_SinglePlayer_pressed():
	#get_tree().change_scene_to_file("res://Recycling_plant.tscn")
	get_node("%MenuContents").current_tab = 5
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


