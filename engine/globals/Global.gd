extends Node


# Global.gd

# global state should, as a rule, go here; e.g. if Player instance persists between levels, store it in a property here and pass it to a newly instantiated Level scene when configuring that level's state; alternatively, mapmakers can position a new Player node in each map (which is probably preferable for mapmakers) and Global holds the player's level-independent state (health, inventory)


# TO DO: for function naming convention, use single leading underscore for Godot event handlers (_ready, _on_area_foo_entered), use double underscores for private functions and vars; do NOT use leading underscores on public properies and methods



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # note: if we ever implement M2-style movie recording (which, IIRC, records and plays back the original mouse and key stroke events) as part of netplay DLC, the recorded game's RNG seed needs to be restored as well so that 'random' events occur in exact same order (I suspect speedrunners etc use video screencapture, but M2-style movies could provide access to all players' cameras, or even an independent user-controlled 'spectator' camera - e.g. a video mode that plays back from viewpoint of Pfhor in the order the user kills them might offer amusement, as would arena cams for netgame spectators)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
