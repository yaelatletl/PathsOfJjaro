extends Node3D


# TO DO: redo this, using same[ish] implementation as the switch in TestPlatform.tscn


@export var isPressed : bool = false # TO DO: might want an enum for this; also need a flag/enum for indicating if a switch is/isn't pressable (M2 used adjustable lighting to enable/disable switches); note: we probably want separate classes for smashable circuits, key card switches, etc (M2 used a single Switch class with multiple flags to modify its behavior but we can afford the luxury of separate classes, which also gives us flexibility on behaviors: e.g. a smashed circuit should emit a flash of light and configurable "bang!" sound when destroyed, followed by smoke and sparks animation which may persist for an adjustable time period)


# TO DO: should Switch.tscn also include a configurable light emitter so that when any switch is turned on it shines brighter than one that is turned off? (note: switch models can also include their own light emitters, ofc; this would be a general environmental light which is part of the engine behavior)


# TO DO: the Switch's model should also be selectable via @export (it may be best to use enums for switch names, rather than use node paths, as enums are more robust); i.e. while we could create a different asset/switch/FooSwitch.tscn for every possible switch design, it will make development and testing easier if we have a small number of behavioral switch types defined as subclasses in engine - e.g. NormalSwitch, BreakableCircuit, RepairableCircuit, KeycardEntry - which can be assigned a specific model when placed into maps (again, this allows us to develop and greybox-test the engine behavior with or without the visual assets connected)


signal pressed # TO DO: don't use signals for switches or doors; whereas we want HUD and WIH to be loosely coupled to engine so the engine can work with or without them (and vice-versa), interacting map nodes should be explicitly connected to one another within the level scene so that any missing connections are reported, not ignored # TO DO: switches should call a `switch_pressed(switch: Switch) -> bool` method on Level which performs all switch dispatch; Level can hold a Dictionary of all switches in the level (Switch._ready should call `Level.add_switch(self)` to register itself with that dictionary), plus another Dictionary of doors/platforms/lights/scripted events/etc; the mapmaker can then define a UID for each object and specify relationships between them in a lookup table - e.g. a single switch may operate one or many doors, a single door may be operated by multiple switches, and switch-door interactions must be two-way so pressing a door switch to open a door activates *all* switches connected to that door; having a central registration system also allows Level._ready to check that all switches and doors are wired up, and log a map error if any unmatched IDs are found


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
