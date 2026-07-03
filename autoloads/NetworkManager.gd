extends Node

var transport: NetworkTransport

func use_local() -> void:
	_set_transport(LocalTransport.new())

func use_enet() -> void:
	_set_transport(ENetTransport.new())

func _set_transport(new_transport: NetworkTransport) -> void:
	if transport and transport.is_inside_tree():
		remove_child(transport)
		transport.queue_free()
	transport = new_transport
	add_child(transport)
