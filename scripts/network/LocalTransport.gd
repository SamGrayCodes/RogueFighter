class_name LocalTransport
extends NetworkTransport

func host(_port: int, _max_peers: int) -> Error:
	connection_succeeded.emit()
	return OK

func join(_address: String, _port: int) -> Error:
	connection_succeeded.emit()
	return OK
