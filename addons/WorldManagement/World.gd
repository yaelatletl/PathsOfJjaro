tool
extends EditorPlugin
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _enter_tree():
	add_custom_type("World", "Navigation", preload("WorldManagement.gd"), preload("icon.png"))
	add_custom_type("PathPoint", "Position3D", preload("PathPoint.gd"), preload("icon.png"))
	add_custom_type("AStarPath", "Path", preload("res://addons/WorldManagement/AStar_Path.gd"), preload("icon.png"))
	add_custom_type("Gravity Area", "Area", preload("GravityArea.gd"), preload("Gravicon.png"))
	add_custom_type("AI","KinematicBody",preload("Basic_3D_AI_Behavior.gd"), preload("IA_icon.png"))
	#add_custom_type("RayCastGun", "Spatial", preload("RaycastGun.gd"), preload("Raygun.png")
	#add_custom_type("BulletGun", "Spatial", peload("Gun.gd"), preload("Gun.png")
func _exit_tree():
	remove_custom_type("World")
	remove_custom_type("Gravity Area")
	remove_custom_type("AI")
	remove_custom_type("PathPoint")
	remove_custom_type("AStarPath")
	#remove_custom_type("RayCastGun")
	#remove_custom_type("BulletGun")