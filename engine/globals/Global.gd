extends Node


# Global.gd

# global state should, as a rule, go here; e.g. if Player instance persists between levels, store it in a property here and pass it to a newly instantiated Level scene when configuring that level's state; alternatively, mapmakers can position a new Player node in each map (which is probably preferable for mapmakers) and Global holds the player's level-independent state (health, inventory)


# TO DO: for function naming convention, use single leading underscore for Godot event handlers (_ready, _on_area_foo_entered), use double underscores for private functions and vars; do NOT use leading underscores on public properies and methods



# note: signals need to be declared in a global node (or some other node which all emitters and listeners can reference); in this case we're connecting: Weapon -> Global.SOME_SIGNAL <- HUD


# TO DO: is it worth moving signal definitions into their own Signals.gd global? (leave them here for now; they can easily be relocated later)

# TO DO: this API is temporary until we figure out the best design for it; most of these signals might be combined into a single `weapon_state_changed([from_state: WeaponState] weapon: Weapon)` - I think this will make the weapon's state changes easier to understand and reason about (and thus robustly implement in WIH view)

# TODO: update WeaponInHand.tscn to listen to these signals to drive its animations; for now, delete the existing Glock model, etc and use a simple cuboid greybox while we work on getting the API and animation tracks designed and working right (once the code all works, the last step is to re-add the correct meshes and skeletons for Fist, Pistol, and AR WIH scenes and polish it; e.g. see the tentacle story in [https://www.youtube.com/watch?v=BQ3iqq49Ew8] for how to develop novel new scenes with lots of complex interactions one step as a time)
#
# only triggers need to be fully independent (AR allows triggers to shoot independently of each other so it's possible for both to fire in the same physics tick); all other states are interlocked (primary and secondary notifications could be merged into a single weapon_fired signal with 2 arguments for primary and secondary trigger states: JUST_FIRED/JUST_FAILED/BUSY/IDLE)
signal weapon_activating(weapon: Weapon)
signal weapon_activated(weapon: Weapon) 

# TO DO:  it's possible for weapon activating animation to be reversed if the user presses previous/next_weapon key multiple times (repeatedly pressing the key quickly will step over weapons without activating any except the last-selected weapon, but pressing it a bit more slowly may cause a weapon's activating animation to start playing without allowing time for it to finish; ideally there should be a single animation that can be played either forward or backward or slowed/paused at any point so it's trivially reversible, otherwise we'll have to interpolate the model between 2 different positions, which may or may not produce a satisfactory animation)

signal weapon_deactivating(weapon: Weapon)
signal weapon_deactivated(weapon: Weapon)



signal primary_trigger_fired(successfully: bool) # passing the Weapon allows recipient to query the weapon's current state as well as the state of the firing trigger (and the other trigger if needed), which should be enough information to drive all the animations
signal secondary_trigger_fired(successfully: bool)


signal primary_trigger_reloaded(successfully: bool)
signal secondary_trigger_reloaded(successfully: bool)



signal inventory_item_changed(item: Inventory.InventoryItem)



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



func add_to_level(node: Node3D) -> void:
	var owner: Node = current_level #.get_tree()
	owner.add_child(node) # TO DO: the current level scene should be available on Global; Global would also handle level loading and anything else that persists across process lifetime (unless Global also ontains lots of non-level logic, in which case put level management code in a dedicated LevelManager singleton)
	node.owner = owner
	#print("added ", node, " to ", owner)

