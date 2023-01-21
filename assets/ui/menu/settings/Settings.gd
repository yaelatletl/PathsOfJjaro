extends VBoxContainer

func _on_Save_pressed():
	pass

func _on_Cancel_pressed():
	get_node("%MenuContents").current_tab = 0
