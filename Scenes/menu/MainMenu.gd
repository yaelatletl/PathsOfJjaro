extends Spatial
var viewport = null
var prev_pos = null
var last_click_pos = null

	
func _input(event):
	# Check if the event is a non-mouse event
	var is_mouse_event = false
	var mouse_events = [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]
	for mouse_event in mouse_events:
		if (event is mouse_event):
			is_mouse_event = true
			break
  
	# If it is, then pass the event to the viewport
	if (is_mouse_event == false):
		viewport.input(event)
		

func _ready():
	# Get the viewport and clear it
	get_node("Area").connect("input_event", self, "_on_area_input_event")
	viewport = $Viewport
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	viewport.size = Vector2(512,256)
	viewport.usage = Viewport.USAGE_2D_NO_SAMPLING
	viewport.render_target_v_flip = true

	# Let two frames pass to make sure the vieport's is captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the texture and set it to the viewport quad
	$Terminal.material_override.albedo_texture = viewport.get_texture()
	$Terminal.material_override.emission_texture = viewport.get_texture()
	$AnimationPlayer.play("Walk")

func _on_Area_input_event(camera, event, click_pos, click_normal, shape_idx):
	# Use click pos (click in 3d space, convert to area space)
	var pos = get_node("Area").get_global_transform().affine_inverse()
	# the click pos is not zero, then use it to convert from 3D space to area space
	if (click_pos.x != 0 or click_pos.y != 0 or click_pos.z != 0):
		pos *= click_pos
		last_click_pos = click_pos
	else:
		# Otherwise, we have a motion event and need to use our last click pos
		# and move it according to the relative position of the event.
		# NOTE: this is not an exact 1-1 conversion, but it's pretty close
		pos *= last_click_pos
		if (event is InputEventMouseMotion or event is InputEventScreenDrag):
			pos.x += event.relative.x / viewport.size.x
			pos.y += event.relative.y / viewport.size.y
			last_click_pos = pos
  
	# Convert to 2D
	pos = Vector2(pos.x, pos.y)
  
	# Convert to viewport coordinate system
	# Convert pos to a range from (0 - 1)
	pos.y *= -1
	pos += Vector2(1, 1)
	pos = pos / 2
  
	# Convert pos to be in range of the viewport
	pos.x *= viewport.size.x
	pos.y *= viewport.size.y
	
	# Set the position in event
	event.position = pos
	event.global_position = pos
	if (prev_pos == null):
		prev_pos = pos
	if (event is InputEventMouseMotion):
		event.relative = pos - prev_pos
	prev_pos = pos
	
	# Send the event to the viewport
	viewport.input(event)
