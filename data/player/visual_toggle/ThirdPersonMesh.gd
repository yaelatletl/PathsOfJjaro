extends MeshInstance

func _ready() -> void:
	if get_tree().has_network_peer():
		if is_network_master():
			set_layer_mask(4)
	else:
		set_layer_mask(4)