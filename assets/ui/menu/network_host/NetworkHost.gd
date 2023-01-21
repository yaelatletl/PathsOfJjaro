extends Tabs

var match_settings : Dictionary = {}
var connection_settings : Dictionary = {}


func _on_NavigationCancel_pressed():
	get_node("%MenuContents").current_tab = 0

func _on_NavigationNext_pressed():
	get_node("%MenuContents").current_tab = 4 # Go to NetworkLobby

func get_connection_settings():
	connection_settings["players"] = get_node("%MaxPlayers/value").value
	connection_settings["port"] = get_node("%HostPort/value").text
	return connection_settings

func get_match_settings():
	match_settings["map"] = get_node("%MapList").get_selected()
	match_settings["mode"] = get_node("%ModeList").get_selected()
	match_settings["aliens"] = get_node("%Aliens").pressed
	match_settings["pvp"] = get_node("%PVP").pressed
	match_settings["friendlyfire"] = get_node("%FriendlyFire").pressed
	match_settings["infiniteammo"] = get_node("%InfiniteAmmo").pressed
	return match_settings

func _on_IP_visibility_changed():
	$HTTPRequest.request("http://ip.42.pl/raw")

func _on_HTTPRequest_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray):
	var json = body.get_string_from_utf8()
	connection_settings["address"] = str(json)



