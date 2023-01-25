extends Control
onready var port = $VBC1/HBC/VBC/HostPort/value
onready var ip = $VBC1/HBC/VBC/HostIP/value

func _on_Cancel_pressed():
	get_node("%MenuContents").current_tab = 0

func _on_Next_pressed():
	if _verify_ip(ip.text):
		get_node("%MenuContents").current_tab = 4
		get_node("%NetworkLobby").setup_from_join(ip.text, port.text)

func message_error(title, message):
	var dialog = $MessageDialog
	dialog.window_title = title
	dialog.dialog_text = message
	dialog.popup_centered()

func _verify_ip(ip):
	if ip == "":
		message_error("No IP given", "Please enter a valid IP Address")
		return
	#Check if the ip is valid and exists
	var ip_regex = RegEx.new()
	ip_regex.compile("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
	var valid = ip_regex.search(ip)
	if valid == null:
		valid = false
	else:
		valid = valid.get_strings().size() > 0
	if not valid:
		message_error("Invalid IP Address", "The IP address you entered is invalid. Please try again.")
		return false
	#ping the ip
	var ping = OS.execute("ping", ["-n 1 " + ip])
	var exists = ping == 0
	print(ping)
	if not exists:
		message_error("IP Address Couldn't be reached", "The IP address you entered could not be reached. Please try again.")
		return false
	return valid and exists
