extends Node3D
class_name SpawnerBase


# TO DO: what is purposer of this?


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

@export_enum("Player", "Character", "Item") var spawn_type  : int 

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
