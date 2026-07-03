class_name HitboxComponent
extends Area2D

var attack_data: AttackData
var _collision_shape: CollisionShape2D

func _ready() -> void:
	_collision_shape = CollisionShape2D.new()
	add_child(_collision_shape)
	deactivate()

func activate(data: AttackData) -> void:
	attack_data = data
	if data.hit_shape:
		_collision_shape.shape = data.hit_shape
	_collision_shape.disabled = false
	monitoring = true

func deactivate() -> void:
	_collision_shape.disabled = true
	monitoring = false
	attack_data = null
