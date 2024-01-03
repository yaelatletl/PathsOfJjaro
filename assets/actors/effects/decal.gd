extends Node3D

# decal.gd -- bullet burn mark; see also burnt_ground.tscn


# TODO: create a single engine/effects/decal.tscn which can be used for all static (map decoration) and dynamic (explosion-inflicted) 2D wall/floor/ceiling decals; see also 3D wall/floor/ceiling greebles

# TODO: get rid of the timeout for now (it's presumably to limit the number of bullet holes being rendered at any one time but smells of premature optimization): 1. it's not necessary that every bullet strike leaves a mark (besides, inflicting 52 holes on a wall when the user unloads a full AR mag will just look bad; Less is More); 2. we can use Godot's Rooms+Portals to limit the number of walls being rendered at any one time; 3. if there is a need to reduce dynamic decals visible in any one area, that can be done by setting a MAX_DECAL_COUNT and freeing older decals when that is exceeded; get the basic implementation working first and worry about performance profiling later


@export var seconds: float

func _ready() -> void:
	var timer = get_tree().create_timer(seconds)
	timer.connect("timeout",Callable(self,"queue_free"))
