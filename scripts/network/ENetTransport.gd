class_name ENetTransport
extends NetworkTransport

var _peer: ENetMultiplayerPeer

func host(port: int, max_peers: int) -> Error:
	_peer = ENetMultiplayerPeer.new()
	var err: Error = _peer.create_server(port, max_peers)
	if err != OK:
		connection_failed.emit("Failed to create server on port %d" % port)
		return err
	multiplayer.multiplayer_peer = _peer
	multiplayer.peer_connected.connect(func(id: int) -> void: peer_connected.emit(id))
	multiplayer.peer_disconnected.connect(func(id: int) -> void: peer_disconnected.emit(id))
	connection_succeeded.emit()
	return OK

func join(address: String, port: int) -> Error:
	_peer = ENetMultiplayerPeer.new()
	var err: Error = _peer.create_client(address, port)
	if err != OK:
		connection_failed.emit("Failed to connect to %s:%d" % [address, port])
		return err
	multiplayer.multiplayer_peer = _peer
	multiplayer.connected_to_server.connect(func() -> void: connection_succeeded.emit())
	multiplayer.connection_failed.connect(func() -> void: connection_failed.emit("Connection failed"))
	multiplayer.peer_connected.connect(func(id: int) -> void: peer_connected.emit(id))
	multiplayer.peer_disconnected.connect(func(id: int) -> void: peer_disconnected.emit(id))
	return OK

func disconnect_all() -> void:
	if _peer:
		_peer.close()
	multiplayer.multiplayer_peer = null
