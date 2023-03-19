extends MeshInstance3D

func _ready() -> void:
	if get_tree().has_multiplayer_peer():
		if is_multiplayer_authority():
			set_layer_mask(4)
	else:
		set_layer_mask(4)