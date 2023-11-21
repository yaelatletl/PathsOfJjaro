extends Node


# Global.gd

# global state should, as a rule, go here; e.g. if Player instance persists between levels, store it in a property here and pass it to a newly instantiated Level scene when configuring that level's state


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
