extends CenterContainer

onready var label = $Text
onready var animator = $AnimationPlayer


func show_message(message):
	label.text = message
	animator.play("FadeIn")

func hide_message():
	animator.play("FadeOut")