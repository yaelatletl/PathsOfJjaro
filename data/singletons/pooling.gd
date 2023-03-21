extends Node

enum DAMAGE_TYPE {
	KINECTIC, 
	ENERGY, 
	SLOWING,
	FIRE,
	EXPLOSIVE 
} 

var projectiles_active : Array = []
var projectiles_waiting : Array = []

var projectiles : Dictionary = {
	1: preload("res://assets/weapons/projectiles/PlasmaBolt.tscn"),
	2: preload("res://assets/weapons/projectiles/Grenade.tscn"),
}

var actor_pool : Dictionary = {}

var projectiles_root 

func setup_projectile_root(root):
	projectiles_root = get_tree().get_root()

func add_projectile(projectile_type,position, direction, actor):
#	print("Position passed to add_projectile: " + position)
	var found = null
	var projectile_instance = null
	for bullet in projectiles_waiting:
		if bullet.type == projectile_type:
			found = bullet
			break
	if found == null:
		projectile_instance = projectiles[projectile_type].instantiate()
		projectile_instance.set_as_top_level(true)
		projectile_instance.connect("request_destroy",Callable(self,"_on_projectile_request_destroy").bind(projectile_instance))
	else:
		projectiles_waiting.erase(found)
		projectile_instance = found
		projectile_instance.sleeping = false
	projectile_instance.add_exceptions(actor)
	projectiles_active.append(projectile_instance)
	projectiles_root.add_child(projectile_instance)
	projectile_instance.move(position, direction)


func _on_projectile_request_destroy(projectile):
	projectiles_active.erase(projectile)
	if projectile.is_inside_tree():
		projectile.sleeping = true
		projectile.linear_velocity = Vector3(0,0,0)
		projectiles_root.call_deferred("remove_child", projectile)
		projectiles_waiting.append(projectile)

#Creates a dummy actor to be used for portal physics
func duplicate_actor(actor):
	if not actor is CharacterBody3D:
		printerr("Passed node is not a CharacterBody3D")
		return null
	if not actor in actor_pool:
		actor_pool[actor] = actor.duplicate(1)
		remove_cameras(actor_pool[actor]) #remove_at cameras from the duplicate
	return actor_pool[actor]

func free_actor_duplicate(actor):
	if not actor is CharacterBody3D:
		printerr("Passed node is not a CharacterBody3D")
		return 
	if actor in actor_pool:
		printerr("Passed node is not a duplicate")
		return
	actor.get_parent().remove_child(actor)

# Remove all cameras that are children of the passed node, for Actors only
func remove_cameras(node: Node) -> void:
	var cam_or_null = node.get_node_or_null("head/neck/camera")
	if  cam_or_null != null:
		cam_or_null.queue_free()
