extends Area3D
class_name DoorActionHandler


# ActionHandler.gd -- detection Area for Player's ActionReach raycast; when player's reach intersects this Area, the Player may modify its appearance (e.g. show a hand poised to press a switch) and can call do_action to activate/toggle whatever the switch is connected to


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



# need to figure out how best to implement control panel mechanics; probably best to define one or more Area3D subclasses and @export its configuration options so mapmakers can connect a control panel's action detection box to a light/door/platform/etc within the 3D editor

# TODO: should the Player call do_action directly or should it call `get_interactable` to get the object to which it sends `do_action` if/when user presses ACTION? (bear in mind that ActionHandler Area != ControlPanel Node, which is typically the Area's parent); returning the object (terminal, recharger, switch, circuit, door, etc) would allow Player to intelligently modify its behavior and display different hand gestures for different panel types

func do_action(activating_body: Node3D) -> void: # pass the activating_body (we'll assume for now this is always the Player, as NPCs wanting to open a door will probably trigger it directly, but this might change in future); when the control panel is a recharger, it will operate directly on the activating_body
	var platform = self.get_parent()
	platform.do_action(activating_body, self) # TBD: API for do_action


