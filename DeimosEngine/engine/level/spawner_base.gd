extends Node3D
class_name SpawnerBase


# TO DO:how is this meant to be used? the current implementation looks problematic: assuming we use some M2-style teleport-in triggers for introducing Pfhor and ammo in player's line of sight (e.g. the downstairs Arrival bar could have its Pfhor party teleport in, which adds some visual interest to the encounter), we want to attach multiple Pfhor to one player-detection Area which activates them all when Player enters it

# Ideally we'd place a group of Pfhor on the map (those that teleport in would use visible=false and teleport_in=true) then add all their paths to an `@export var bodies: Array[NodePath]` on a PlayerDetectionArea which is placed in the map at the trigger location. However, need to confirm first that GDScript and Editor can handle this (its support for generic types is eccentric and limited); we could probably use the same triggering API on PickableItem so ammo can also be teleported in. Assuming this'll work, recreate this as a subclass of Area3D so it can be placed directly into maps.


enum SPAWN_TYPE {
	PLAYER, 
	CHARACTER,
	ITEM
}

@export var spawn_on_ready : bool = true 
@export var spawn_on_body_enter : bool = false
@export var spawn_on_body_exit : bool = false

@export_node_path var area_trigger_path : NodePath = NodePath("")

@onready var area_trigger : Area3D = get_node(area_trigger_path)

@export_enum("Player", "NPC", "Item") var spawn_type  : int 

@export var identifier : String = "Default:NULL"

@onready var object = get_object(identifier)

# Called when the node enters the scene tree for the first time.
func _ready():
	if spawn_on_ready:
		spawn()
	if spawn_on_body_enter:
		area_trigger.body_entered.connect(self.spawn)
	if spawn_on_body_exit:
		area_trigger.body_exited.connect(self.spawn)

func get_object(id : String):
	pass

func spawn():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
