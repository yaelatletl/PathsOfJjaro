extends CanvasLayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var health = 100
var oxygen = 1000
var debug = false



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#print(get_viewport().size)
	get_tree().get_root().connect("size_changed", self, "myfunc")
	scale.x = (get_viewport().size.x/1920)
	scale.y = (get_viewport().size.y/1080)
	change_health(health)
	change_oxygen(oxygen)
	pass

func myfunc():
	scale.x = (get_viewport().size.x/1920)
	scale.y = (get_viewport().size.y/1080)
	#print("Resizing: ", get_viewport().size)
	pass

func _input(event):
	#print(health)
	#print(oxygen)
	
	if debug == false:
		pass
	elif debug == true:
		if event.is_action_pressed("healthup"):
			if health >= 300:
				health = 300
				pass
			else:
				health += 1
		elif event.is_action_pressed("healthdown"):
			if health <= 0:
				health = 0
				pass
			else:
				health -= 1

		if event.is_action_pressed("oxygenup"):
			if oxygen >= 1000:
				oxygen = 1000
				pass
			else:
				oxygen += 1
		elif event.is_action_pressed("oxygendown"):
			if oxygen <= 0:
				oxygen = 0
				pass
			else:
				oxygen -= 1

	else:
		pass
	
	change_health(health)
	change_oxygen(oxygen)
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func change_health(health):
	if health >= 1 and health <= 100:
		get_node("Health|Radar/x1").indicator_value = float(health)/100
	elif health <= 0:
		get_node("Health|Radar/x1").indicator_value = 0
	elif health >= 100:
		get_node("Health|Radar/x1").indicator_value = 1

	if health >= 101 and health <= 200:
		get_node("Health|Radar/x2").indicator_value = float(health-100)/100
	elif health <= 100:
		get_node("Health|Radar/x2").indicator_value = 0
	elif health >= 200:
		get_node("Health|Radar/x2").indicator_value = 1

	if health >= 201 and health <= 300:
		get_node("Health|Radar/x3").indicator_value = float(health-200)/100
	elif health <= 200:
		get_node("Health|Radar/x3").indicator_value = 0
	elif health >= 300:
		get_node("Health|Radar/x3").indicator_value = 1

	if health <= 0:
		get_node("Health|Radar/x1").indicator_value = 0
		get_node("Health|Radar/x2").indicator_value = 0
		get_node("Health|Radar/x3").indicator_value = 0
	pass



func change_oxygen(oxygen):
	if oxygen >= 1 and oxygen <= 1000:
		get_node("Health|Radar/Oxygen").indicator_value = float(oxygen)/1000
	elif oxygen <= 0:
		get_node("Health|Radar/Oxygen").indicator_value = 0
	elif oxygen >= 1000:
		get_node("Health|Radar/Oxygen").indicator_value = 1

	pass