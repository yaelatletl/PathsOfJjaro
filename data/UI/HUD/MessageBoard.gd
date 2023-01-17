extends VBoxContainer

var message_count = 0

func add_message(message, time_left, delete_on_signal = ""):
	var label = Label.new()
	label.set_text(message)
