extends Node3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var speed: float = 100
@export var direction: Vector3= Vector3(0, 0, 0)
@onready var plataform = $CharacterBody3D
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
	if body is Actor3D: # TODO: don't do this; set up Collision Layers (Wall, Floor, Ceiling, Player, Enemy, Projectile, Pickable, DestructibleScenery, IndestructibleScenery, DestructibleGreeble, IndestructibleGreeble, DestructibleWindow, IndestructibleWindow, etc) and use masks to filter (GodotEditor's GUI is crap, so print a cheatsheat of layer names to off-by-1 bit numbers)
		isplayerinside = not isplayerinside
		print("Player entered the area")
	#If body entered && Input
	#bandera; quiero que el usuario presione usar DENTRO del area


func _on_area_3d_body_exited(body):
	if body is Actor3D:
		isplayerinside = not isplayerinside
		print("Player leaved the area")


func _on_switch_pressed():
	print("Switch pressed")
	active = not active
