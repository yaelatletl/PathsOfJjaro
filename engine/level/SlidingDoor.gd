extends Node3D
class_name SlidingDoor


# TO DO: similar implementation to Platform, although it won't be identical as, unlike Classic (platforms are sliding vertical columns, i.e. adjustable ceiling and/or floor heights), MCR platforms are moving ledges so must check for colliding objects both above AND underneath (whereas Doors only need to check for colliders within the door gap); while we may be able to factor out common logic from both into an abstract base class, let's initially implement as separate scripts


# note that using Animatable instead of Static means that closing doors can push a Player/NPC (handy for crushing doors, though safety doors might try using move_and_collide to close so they stop on collision and reverse immediately); for now, inclined to save RigidBody for swing doors only, and using AnimatableBody for horizontal and vertical sliding doors and platforms


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
