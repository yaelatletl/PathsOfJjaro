extends Spatial


var mapRID 
var regions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	mapRID = NavigationServer.map_create()

func get_path():
	var path = []
	