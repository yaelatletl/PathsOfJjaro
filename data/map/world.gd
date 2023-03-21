extends Node3D


var mapRID : RID = RID()
var regions : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapRID = NavigationServer3D.map_create()
	regions = get_tree().get_nodes_in_group("nav_regions")
	
func _physics_process(delta):
	#NavigationServer3D.process(delta)
	pass
