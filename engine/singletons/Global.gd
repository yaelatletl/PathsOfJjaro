extends Node


# Global.gd

# global state should, as a rule, go here; e.g. if Player instance persists between levels, store it in a property here and pass it to a newly instantiated Level scene when configuring that level's state


# TO DO: for function naming convention, use single leading underscore for Godot event handlers (_ready, _on_area_foo_entered), use double underscores for private functions and vars; do NOT use leading underscores on public properies and methods



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
