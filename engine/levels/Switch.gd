extends Node3D

@export var isPressed : bool = false 

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("ui_select") and isPressed:
		pressed.emit()
		print("pressed")

func _on_area_3d_body_entered(body:Node3D):
	#if body is Actor3D:
		print("Player within switch range")
		isPressed = not isPressed
		#pressed.emit()

func _on_area_3d_body_exited(body:Node3D):
	#if body is Actor3D:
		print("Player left switch range")
		isPressed = not isPressed
		#pressed.emit(
