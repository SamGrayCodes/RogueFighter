class_name Platform
extends StaticBody2D

@export var one_way: bool = false

func _ready() -> void:
	if one_way:
		collision_layer = 4
		collision_mask = 0
