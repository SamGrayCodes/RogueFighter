extends Node

var transport: NetworkTransport

func use_local() -> void:
	transport = LocalTransport.new()

func use_enet() -> void:
	transport = ENetTransport.new()
