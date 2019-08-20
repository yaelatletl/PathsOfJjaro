tool
extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _draw():
	draw_rect(Rect2(Vector2(get_rect().size.x-get_rect().size.x,get_rect().size.y-get_rect().size.y),Vector2(get_rect().size.x,get_rect().size.y)),Color(0,0,0,.2))
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
