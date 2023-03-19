extends Node3D


var mapRID 
var regions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	mapRID = NavigationServer3D.map_create()

func get_path():
	var path = []
	