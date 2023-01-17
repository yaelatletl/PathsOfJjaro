extends MeshInstance


func _ready() -> void:
	if get_tree().has_network_peer():
		if not is_network_master():
			set_layer_mask(4)