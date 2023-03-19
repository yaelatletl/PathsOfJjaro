extends Node3D

@export var spawn_points_parent_path: NodePath : NodePath = ""
@onready var spawnpoint_parent = get_node(spawn_points_parent_path)

var players_in_local_instance : Dictionary = {}
var spawn_point_in_turn = 0
func _ready() -> void:
	Gamestate.connect("players_changed",Callable(self,"_on_Gamestate_players_changed"))
	Pooling.setup_projectile_root(self)

func _on_Gamestate_players_changed():
	for player in Gamestate.players:
		if $players.has_node(str(player)):
			pass
		else:
			var current_children = spawnpoint_parent.get_children()
			Gamestate.players[player].global_transform = current_children[spawn_point_in_turn].global_transform
			spawn_point_in_turn += 1
			$players.add_child(Gamestate.players[player])
	for player in $players.get_children():
		if not int(player.name) in Gamestate.players:
			player.queue_free()
