tool
extends EditorPlugin
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _enter_tree():
	add_custom_type("World", "Navigation", preload("WorldManagement.gd"), preload("icon.png"))
	add_custom_type("Gravity Area", "Area", preload("GravityArea.gd"), preload("Gravicon.png"))
	add_custom_type("AI","KinematicBody",preload("Basic_3D_AI_Behavior.gd"), preload("IA_icon.png"))
func _exit_tree():
	remove_custom_type("World")
	remove_custom_type("Gravity Area")
	remove_custom_type("AI")