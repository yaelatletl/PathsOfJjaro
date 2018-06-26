extends Spatial

func _ready():
	# Get the viewport and clear it
	var viewport = $Viewport
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