extends Position3D


export(int) var idx
export(bool) var bidirectional = true
export(NodePath) var next_point = null
var disconnected = false

func _process(delta):
	
	if next_point!=null:
		disconnected = false
	

func _ready():
	if disconnected:
		add_to_group("map_roads")

	if Engine.editor_hint:
		set_notify_transform(true)

	draw_debug_line()
		
func _notification(what):
	if Engine.editor_hint:
		if what == Spatial.NOTIFICATION_TRANSFORM_CHANGED:
			draw_debug_line()
		
func draw_debug_line():
	if Engine.editor_hint:
		if not disconnected:
			if not imm:
				imm = ImmediateGeometry.new()
				add_child(imm)
			imm.clear()
			imm.begin(Mesh.PRIMITIVE_LINES)
			if get_parent():
				imm.add_vertex(to_local(get_parent().global_transform.origin))
				imm.set_color(Color(0.0, 0.0, 0.0))
				imm.add_vertex(Vector3(0.0, 0.0, 0.0))
				imm.end()
		else:
			if imm:
				imm.clear()