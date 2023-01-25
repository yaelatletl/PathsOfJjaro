extends LineEdit
export(bool) var allow_points = false

func _on_value_text_changed(text_in):
	var new_text = ""
	for i in range(text_in.length()):
		var c = text_in[i]
		if c >= "0" and c <= "9" or (allow_points and c =="." ):
			new_text += c

	text = new_text
	caret_position += text_in.length()
