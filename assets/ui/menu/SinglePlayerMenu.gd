extends Control

func _on_newGame_pressed():
	get_tree().change_scene_to_file("res://Main_test_scene.tscn")
	#Load here Arrival
	pass

func _on_Select_pressed():
	#Popup menu for mission select. 
	pass

func _on_SavedGame_pressed():
	#New Interface for saved games. 
	pass # Replace with function body.

func _on_Recorded_pressed():
	#Check recorded games. 
	pass # Replace with function body.

func _on_Cancel_pressed():
	get_node("%MenuContents").current_tab = 0 #Return to main menu.
