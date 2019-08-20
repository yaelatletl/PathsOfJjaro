tool
extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var circle_size = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#draw_circle(Vector2(0,0),20,Color(1,1,1,1))
	pass

func _draw():
	draw_circle(Vector2(circle_size/2,circle_size/2),circle_size/2,Color(0,0,0,.2))
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Radar_item_rect_changed():
	if get_rect().size.x > get_rect().size.y:
		circle_size = get_rect().size.y
	elif get_rect().size.x < get_rect().size.y:
		circle_size = get_rect().size.x
	else:
		if circle_size != get_rect().size.x and circle_size != get_rect().size.y:
			circle_size = get_rect().size.x
		else:
			circle_size = circle_size
		pass
		
	pass # replace with function body
