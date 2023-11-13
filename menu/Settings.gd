extends VBoxContainer




func _on_button_go_to_main_menu_pressed():
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
