extends Control
var AO



func _on_Settings_pressed():
	$Controls.visible=true
	$Main.visible = false
	$TabContainer.visible = true


func _on_Cancel_pressed():
	$Controls.visible=false
	$Main.visible = true
	$TabContainer.visible = false
	$Net_Host.visible = false

func _on_AO_pressed():
	pass

func _on_IP_visibility_changed():
	$HTTPRequest.request("http://ip.42.pl/raw")
	

func _on_HostNet_pressed():
	$Main.visible = false
	$Controls.visible = true
	$Net_Host.visible = true
	pass # replace with function body


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = body.get_string_from_utf8()
	if $Net_Host/IP.visible == true:
		$Net_Host/IP.text = "Public IP: " + str(json)




func _on_Play_pressed():
	get_tree().change_scene("res://Recycling_plant.tscn")
	pass # Replace with function body.
