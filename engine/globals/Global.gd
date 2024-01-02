extends Node


# Global.gd

# global state should, as a rule, go here; e.g. if Player instance persists between levels, store it in a property here and pass it to a newly instantiated Level scene when configuring that level's state; alternatively, mapmakers can position a new Player node in each map (which is probably preferable for mapmakers) and Global holds the player's level-independent state (health, inventory)


# TO DO: for function naming convention, use single leading underscore for Godot event handlers (_ready, _on_area_foo_entered), use double underscores for private functions and vars; do NOT use leading underscores on public properies and methods

# TO DO:  it's possible for weapon activating animation to be reversed if the user presses previous/next_weapon key multiple times (repeatedly pressing the key quickly will step over weapons without activating any except the last-selected weapon, but pressing it a bit more slowly may cause a weapon's activating animation to start playing without allowing time for it to finish; ideally there should be a single animation that can be played either forward or backward or slowed/paused at any point so it's trivially reversible, otherwise we'll have to interpolate the model between 2 different positions, which may or may not produce a satisfactory animation)




# health status signals

signal oxygen_changed() # while oxygen/shield increment/decrement could be reported as health_changed, it doesn't really simplify things (since it needs an DamageType.OXYGEN constant added and listeners must implement an extra conditional test to handle it; plus shield hits probably want to take the original DamageType enum so it can display different screen effects for different types of impact)
signal health_changed(damage_type: Enums.DamageType) # M2 calls health "shields" (unlike DOOM, M2 doesn't have separate health plus optional ablative armor which reduces health damage), but since it is running out of health which kills you we use DOOM-style nomenclature in code
signal player_died(damage_type: Enums.DamageType)



signal time_left_changed(value: float) # used by HUD's center counter; currently unused


# Level management


var current_level: Node # currently set by LevelBase._ready; TO DO: once Global (or LevelManager) manages level loading, this may change to SceneTree


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # note: if we ever implement M2-style movie recording (which, IIRC, records and plays back the original mouse and key stroke events) as part of netplay DLC, the recorded game's RNG seed needs to be restored as well so that 'random' events occur in exact same order (I suspect speedrunners etc use video screencapture, but M2-style movies could provide access to all players' cameras, or even an independent user-controlled 'spectator' camera - e.g. a video mode that plays back from viewpoint of Pfhor in the order the user kills them might offer amusement, as would arena cams for netgame spectators)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func array_to_vector3(arr: Array) -> Vector3:
	return Vector3(arr[0], arr[1], arr[2])

func vector3_to_array(vec: Vector3) -> Array:
	return [vec.x, vec.y, vec.z]


func enum_to_string(value: int, enum_type) -> String:
	for key in enum_type.keys():
		if enum_type[key] == value:
			return key
	return "??"



func add_to_level(node: Node3D) -> void:
	var owner: Node = current_level #.get_tree()
	owner.add_child(node) # TO DO: the current level scene should be available on Global; Global would also handle level loading and anything else that persists across process lifetime (unless Global also ontains lots of non-level logic, in which case put level management code in a dedicated LevelManager singleton)
	node.owner = owner
	#print("added ", node, " to ", owner)



func enter_level() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func exit_level() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

