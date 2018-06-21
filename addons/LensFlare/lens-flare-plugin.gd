tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("LensFlare", "Node",preload("res://addons/LensFlare/lens-flare.gd"),preload("res://addons/LensFlare/lens_flare_icon.png")
	)

func _exit_tree():
	remove_custom_type("LensFlare")
