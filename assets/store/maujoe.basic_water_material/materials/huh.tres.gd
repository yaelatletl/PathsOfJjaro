extends MeshInstance
var time = 0.0
var matel
func _ready():
	pass
func _process(delta):
	time =+ delta
	
	material/0.uv1_offset.x = sin(time+4*3.14)
	material/0.uv1_offset.y = sin(3.14*time+10)