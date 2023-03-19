extends RigidBody3D

@export sync var health : int = 100
var remove_decal : bool = false

puppet var on_the_net_transform := Transform3D()

func _ready():

	$timer.connect("timeout",Callable(self,"queue_remove"))
	$explosion/timer.connect("timeout",Callable(self,"_explode_others"))

func _physics_process(delta: float) -> void:
	if get_tree().has_multiplayer_peer():
		if get_tree().is_server():
			rset_unreliable("on_the_net_transform", transform)
		else:
			transform = on_the_net_transform
func _damage(damage, type) -> void:
	if health > 0:
		var dam_calc = health - damage
		
		$audios/impact.pitch_scale = randf_range(0.9, 1.1)
		$audios/impact.play()
		
		if dam_calc <= 0:
			health -= damage
			_explosion()
			$explosion/timer.start()
			$timer.start()
		else:
			health -= damage

func _process(_delta) -> void:
	_remove_decal()

@rpc("any_peer") func _explosion(exploded_in_server : bool = false) -> void:

	
	if get_tree().is_server():
		for players in Gamestate.players:
			if players != 1:
				rpc_unreliable_id(players, "_explosion", true)
	if (not exploded_in_server and get_tree().has_multiplayer_peer()) and not get_tree().is_server():
		return

	$collision.disabled = true

	
	var main = get_tree().get_root().get_child(0)
	
	var burnt_ground = preload("res://data/scenes/burnt_ground.tscn").instantiate()
	main.add_child(burnt_ground)
	burnt_ground.position = global_transform.origin
	
	mode = FREEZE_MODE_STATIC
	
	$mesh.visible = false
	$effects/ex.emitting = true
	$effects/plo.emitting = true
	$effects/sion.emitting = true
	$audios/explosion.pitch_scale = randf_range(0.9, 1.1)
	$audios/explosion.play()
	
	remove_decal = true

@rpc("any_peer") func remote_queue_remove() -> void:
	queue_free()

func queue_remove() -> void:
	if get_tree().is_server():
		queue_free()
	Gamestate.call_on_all_clients(self, "remote_queue_remove", null)

func _remove_decal():
	if remove_decal:
		for child in get_child_count():
			if get_child(child).is_in_group("decal"):
				get_child(child).queue_free()

func _explode_others():
	for bodie in $explosion.get_overlapping_bodies():
		if bodie.has_method("_damage") and bodie != self:
			if "health" in bodie:
				if bodie.health > 0:
					var explosion_distance = (5 * bodie.global_transform.origin.distance_to(global_transform.origin))
					bodie._damage(300 - explosion_distance, Pooling.DAMAGE_TYPE.EXPLOSIVE)
