extends Control

func _on_Begin_pressed():
	var lobby = get_node("%NetworkHost")
	begin_network_game(lobby.get_connection_settings(), lobby.get_match_settings())

func _on_Cancel_pressed():
	get_node("%MenuContents").current_tab = 1

func begin_network_game(connection_settings, match_settings):
	#TODO: Add a check to see if the connection settings are valid
	pass