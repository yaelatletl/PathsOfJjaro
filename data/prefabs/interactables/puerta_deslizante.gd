extends Node3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed: float = 100
@export var direction: Vector3= Vector3(0, 0, 0)
@onready var plataform = $CharacterBody3D
@onready var marker1 = $Marker3D
@onready var marker2 = $Marker3D2
#Enfrente es -Z y atras es +Z
#Derecha es +X y izquierda es -X
@export var active : bool = false 
func _physics_process(delta):
	#compare_position()
	mover(delta)
	plataform.move_and_slide( )
func mover(delta):	
	if active == true:
		compare_position()
		plataform.velocity = direction * speed*delta
		print("moving")
	else:
		plataform.velocity = direction * 0
		print("not moving")
func _input(event):
	#Toggle plataform by pressing F
	if event is InputEventKey:
		if event.is_action_pressed("ui_select"):
			active = not active
			print("active")	

func compare_position():
	#print(plataform.position.y-marker1.position.y)
	if (plataform.position.y - marker1.position.y)<=0:
		active = not active
		print("Reached the Plataform limit")
		#await (get_tree().create_timer(2))
		active = not active
		direction = direction* -1
		#invertmovement = not invertmovement
	if ((plataform.position.y - marker2.position.y))>=0:
		active = not active
		print("Reached the Plataform limit")
		await (get_tree().create_timer(2))
		active = not active
		direction = direction* -1
		#invertmovement = not invertmovement
