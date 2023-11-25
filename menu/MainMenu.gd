extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://levels/Main_test_scene.tscn") # temporary; jump straight into test map on launch
	

func _on_Main_test_scene_pressed():
	get_tree().change_scene_to_file("res://levels/Main_test_scene.tscn")


func _on_Arrival_test_pressed():
	get_tree().change_scene_to_file("res://levels/Arrival_test.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://menu/Settings.tscn")


func _on_quit_pressed():
	get_tree().quit()
