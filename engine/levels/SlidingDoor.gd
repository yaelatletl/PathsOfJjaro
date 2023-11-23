extends Node3D

# this is set up in test map as a rising/falling platform which is ACTION-activated

# TO DO: should doors and platforms have their own collision layer? or can they use same layer as Level wall?


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var speed: float = 100
@export var direction: Vector3= Vector3(0, 0, 0) # TO DO: why is this exported? also, if using markers for extents the direction should be calculated from those: (marker2-marker1).normalized()
@onready var plataform = $CharacterBody3D # TO DO: why not RigidBody3D? CharacterBody is intended for a user-controlled body

# markers indicate extent of movement
@onready var marker1 = $Up
@onready var marker2 = $Down

#Enfrente es -Z y atras es +Z
#Derecha es +X y izquierda es -X
@export var active : bool = false 
@onready var isplayerinside : bool = false


func _physics_process(delta):
	#compare_position()
	mover(delta)
	plataform.move_and_slide( )

func mover(delta):	
	if active == true:
		compare_position()
		plataform.velocity = direction * speed*delta
		#print("moving")
	else:
		plataform.velocity = direction * 0
		#print("not moving")

func _input(event):
	#Toggle plataform by pressing F
	#if event is InputEventKey and isplayerinside:
	
		# this is no good: the player needs to look at, and be in range of, the control panel when pressing ACTION key, so use Player's LineOfSight raycast for panel detection and from the raycast get the control panel it's colliding with and send a do_action(...) message to it
		# (or, in the case of player/npc-activated platforms, stepping onto the platform triggers it: a platform only responds to ACTION key if its 'door' flag is set)
		if event.is_action_pressed("ui_select") and isplayerinside:
			active = not active
			print("Player entered the area and activated the elevator")	

func compare_position():
	#Esta funcion revisa si la posicion del objeto esta acercandose a la posicion indicada en sus markers
	#print(plataform.position.y-marker1.position.y)
	#Marker 1 es up marker 2 es down
	if (plataform.position.y - marker1.position.y)<=0:
		active = not active
		#print("Reached the Superior Limit")
		await (get_tree().create_timer(2))
		active = not active
		direction = direction* -1
		#invertmovement = not invertmovement
	if ((plataform.position.y - marker2.position.y))>=0:
		active = not active
		#print("Reached the Inferior Limit")
		await (get_tree().create_timer(2))
		active = not active
		direction = direction* -1
		#invertmovement = not invertmovement



func _on_area_3d_body_entered(body):
	#if body is Actor3D: # TODO: don't do this; set up Collision Layers (Wall, Floor, Ceiling, Player, Enemy, Projectile, Pickable, DestructibleScenery, IndestructibleScenery, DestructibleGreeble, IndestructibleGreeble, DestructibleWindow, IndestructibleWindow, etc) and use masks to filter (GodotEditor's GUI is crap, so print a cheatsheat of layer names to off-by-1 bit numbers)
		isplayerinside = not isplayerinside
		print("Player entered the area")
	#If body entered && Input
	#bandera; quiero que el usuario presione usar DENTRO del area


func _on_area_3d_body_exited(body):
	#if body is Actor3D:
		isplayerinside = not isplayerinside
		print("Player leaved the area")


func _on_switch_pressed():
	print("Switch pressed")
	active = not active
