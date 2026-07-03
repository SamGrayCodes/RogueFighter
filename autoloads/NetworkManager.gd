extends Node

## Facade over the active NetworkTransport and Godot's multiplayer singleton.
## Owns the connection lifecycle (host/join), tracks the connected peer roster,
## and coordinates the transition from lobby into the match across all peers.

signal roster_changed
signal connection_succeeded
signal connection_failed(reason: String)

const MAX_PLAYERS: int = 4
const DEFAULT_PORT: int = 24545
const GAME_WORLD_SCENE: String = "res://scenes/game/GameWorld.tscn"

var transport: NetworkTransport

## Remote peer ids currently connected (server-side view; excludes self).
var connected_peers: Array[int] = []

func is_networked() -> bool:
	return multiplayer.has_multiplayer_peer()

func is_host() -> bool:
	return not is_networked() or multiplayer.is_server()

func host_game(port: int = DEFAULT_PORT) -> Error:
	use_enet()
	_wire_transport_signals()
	return transport.host(port, MAX_PLAYERS)

func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	use_enet()
	_wire_transport_signals()
	return transport.join(address, port)

func leave() -> void:
	if transport:
		transport.disconnect_all()
	connected_peers.clear()
	roster_changed.emit()

func use_local() -> void:
	_set_transport(LocalTransport.new())

func use_enet() -> void:
	_set_transport(ENetTransport.new())

## Host-only: freeze the roster into GameState and move every peer into the match.
func start_match() -> void:
	if not is_host():
		return
	_build_roster()
	_begin_match.rpc()
	_enter_game()

func _wire_transport_signals() -> void:
	transport.peer_connected.connect(_on_peer_connected)
	transport.peer_disconnected.connect(_on_peer_disconnected)
	transport.connection_succeeded.connect(func() -> void: connection_succeeded.emit())
	transport.connection_failed.connect(func(reason: String) -> void: connection_failed.emit(reason))

func _on_peer_connected(id: int) -> void:
	if not connected_peers.has(id):
		connected_peers.append(id)
	roster_changed.emit()

func _on_peer_disconnected(id: int) -> void:
	connected_peers.erase(id)
	roster_changed.emit()

func _build_roster() -> void:
	GameState.clear_players()
	var peer_ids: Array[int] = [multiplayer.get_unique_id()]
	peer_ids.append_array(connected_peers)
	peer_ids.sort()
	for index: int in peer_ids.size():
		GameState.add_player(index, &"sam", peer_ids[index] == multiplayer.get_unique_id(), peer_ids[index])

@rpc("authority", "call_remote", "reliable")
func _begin_match() -> void:
	_enter_game()

func _enter_game() -> void:
	get_tree().change_scene_to_file(GAME_WORLD_SCENE)

func _set_transport(new_transport: NetworkTransport) -> void:
	if transport and transport.is_inside_tree():
		remove_child(transport)
		transport.queue_free()
	transport = new_transport
	add_child(transport)
