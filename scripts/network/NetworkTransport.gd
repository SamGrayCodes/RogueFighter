class_name NetworkTransport
extends RefCounted

signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal connection_succeeded
signal connection_failed(reason: String)

func host(_port: int, _max_peers: int) -> Error:
	return ERR_UNAVAILABLE

func join(_address: String, _port: int) -> Error:
	return ERR_UNAVAILABLE

func disconnect_all() -> void:
	pass
