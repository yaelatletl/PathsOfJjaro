extends Node3D

# LevelBase.gd


# TO DO: eliminate 5D space in all M1 solo maps - that saves us having to support it (Q. does M3 use 5D as a gameplay element?)


var mapRID : RID = RID()
var regions : Array = []
  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapRID = NavigationServer3D.map_create()
	regions = get_tree().get_nodes_in_group("nav_regions")
	Global.current_level = self # TO DO: sufficient for now; delete once level management is implemented


func _physics_process(delta):
	#NavigationServer3D.process(delta)
	pass

