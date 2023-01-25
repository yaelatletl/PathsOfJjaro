extends Control
var seen_from_join = false

onready var ip_label = $VBoxContainer/HBoxContainer/Info/IP/value
onready var port_label = $VBoxContainer/HBoxContainer/Info/Port/value

func _on_Begin_pressed():
	var lobby = get_node("%NetworkHost")
	begin_network_game(lobby.get_connection_settings(), lobby.get_match_settings())

func _on_Cancel_pressed():
	get_node("%MenuContents").current_tab = 1

func begin_network_game(connection_settings, match_settings):
	#TODO: Add a check to see if the connection settings are valid
	pass

func setup_for_joining(ip, port):
	seen_from_join = true
	ip_label.text = str(ip)
	port_label.text = str(port)
	pass

func setup_for_hosting():
	seen_from_join = false

	pass


func _on_value_visibility_changed():
	if seen_from_join: 
		return
	var lobby = get_node("%NetworkHost")
	lobby._on_IP_visibility_changed()
	ip_label.text = lobby.get_connection_settings().address
	port_label.text = lobby.get_connection_settings().port

