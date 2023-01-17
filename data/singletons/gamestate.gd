extends Node

const SERVER_PORT = 1337
const MAX_PLAYERS = 8
var SERVER_IP = "localhost"
var player_template = preload("res://data/player/character.tscn")
signal players_changed()
#First, let's try to define what do we need our gamestate to do
#we know that we must manage our incoming connections, check them for all players 
#and that we must inform disconnections and so on.

#The network model will go like this:
#A central server is responsible for all the in-game calculations. 
onready var peer = NetworkedMultiplayerENet.new()
var players : Dictionary = {}
var sync_threads = {}

func start_new_sync_process(node, property_name, args) -> void:
	print("DEPRECATED, called from " + node.name + "." + property_name)
	return
	if not get_tree().has_network_peer() or not get_tree().is_network_server():
		return
	var thread = Thread.new()
	var peer_id = node.multiplayer.get_network_unique_id()
	sync_threads[peer_id] = {}
	sync_threads[peer_id][property_name] = thread
	thread.start(self, "_sync_process", [peer_id, node, property_name, args])

#This is a sync process, but it's not working as it should, we will try to limit thread creation to every two players
func _sync_process(args) -> void:
	if sync_threads.has(args[0]):
		var node = args[1]
		var property = args[2]
		var value = args[3]
		Gamestate.set_in_all_clients(node, property, value)
		yield(get_tree().create_timer(5), "timeout")
		_sync_process(args)

func _ready() -> void:
	peer.connect("connection_succeeded", self, "_on_NetworkPeer_connection_succeeded")
	peer.connect("connection_failed", self, "_on_NetworkPeer_connection_failed")
	peer.connect("peer_connected", self, "_on_NetworkPeer_peer_connected")
	peer.connect("peer_disconnected", self, "_on_NetworkPeer_peer_disconnected")
	peer.connect("server_disconnected", self, "_on_NetworkPeer_server_disconnected")
	for args in OS.get_cmdline_args():
		if args == "client":
			client_setup()
		if args == "server":
			server_setup()
	peer.allow_object_decoding = true

func server_setup() -> void:
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	register_player(1)

func client_setup() -> void:
	peer.create_client(IP.resolve_hostname(SERVER_IP), SERVER_PORT)
	get_tree().network_peer = peer

func _on_NetworkPeer_server_disconnected() -> void:
	get_tree().network_peer = null
	pass

func _on_NetworkPeer_peer_disconnected(peer_id : int) -> void:
#	var temp_threads = {}
#	for threads in sync_threads[peer_id]:
#		temp_threads[threads] = sync_threads[peer_id][threads]
#	sync_threads.erase(peer_id)
#	for threads in temp_threads:
#		temp_threads[threads].wait_to_finish()
	players.erase(peer_id)
	emit_signal("players_changed")
	
func _on_NetworkPeer_peer_connected(peer_id : int) -> void:
	if get_tree().is_network_server():
		register_player(peer_id)
		for peers in players:
			for player in players:
				if peers != 1:
					rpc_id(peers, "register_player", player)
					
func _on_NetworkPeer_connection_failed() -> void:
	pass
	
func _on_NetworkPeer_connection_succeeded() -> void:
	pass

func create_player(id : int) -> KinematicBody:
	var new_player =  player_template.instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	return new_player

remote func register_player(peer_id):
	if not players.has(peer_id):
		players[peer_id] = create_player(peer_id)
	emit_signal("players_changed")
	
func call_on_all_clients(object : Node, func_name : String , args) -> void:
	if not get_tree().has_network_peer():
		return
	var exclude = 1
	if not is_instance_valid(object):
		print("Invalid object")
		return
	if object.is_network_master():
		exclude = object.multiplayer.get_network_unique_id()
	
	if get_tree().is_network_server():
		for player in players:
			if player != 1 and player != exclude:
				# print("Calling RPC on client " + str(player))
				if args == null:
					object.rpc_id(player, func_name)
				else:
					object.rpc_id(player, func_name, args)

func set_in_all_clients(object : Node, property_name : String, value) -> void:
	if not get_tree().has_network_peer():
		return
	if not is_instance_valid(object):
		print("Invalid object")
		return
	if get_tree().is_network_server():
		for player in players:
			if player != 1:
				#print("Setting property on client " + str(player))
				object.rset_id(player, property_name, value)

func unreliable_set_in_all_clients(object : Node, property_name : String, value) -> void:
	if not get_tree().has_network_peer():
		return
	if not is_instance_valid(object):
		print("Invalid object")
		return
	if get_tree().is_network_server():
		for player in players:
			if player != 1:
				#print("Setting property on client " + str(player))
				object.rset_unreliable_id(player, property_name, value)

func spawn_instance(parent : Node, scene : PackedScene) -> Node:
	var ref = scene.instance()
	if not get_tree().has_network_peer():
		if is_instance_valid(parent):
			parent.add_child(ref)
			return ref
		return null
	if not is_instance_valid(parent):
		return null
	if get_tree().is_network_server():
		call_on_all_clients(self, "spawn_instance", scene)
	parent.add_child(ref)
	return ref

func remove_node(removed : Node) -> void:
	if not get_tree().has_network_peer():
		if is_instance_valid(removed):
			removed.queue_free()
		return
	if not is_instance_valid(removed):
		return
	if get_tree().is_network_server():
		call_on_all_clients(self, "remove_node", removed)
	removed.queue_free()