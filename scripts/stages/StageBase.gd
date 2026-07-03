class_name StageBase
extends Node2D

@export var stage_id: StringName = &""
@export var display_name: String = ""
@export var spawn_points: Array[NodePath] = []
@export var camera_bounds: Rect2 = Rect2(-640.0, -360.0, 1280.0, 720.0)

var _blast_zones: Array[Area2D] = []

func _ready() -> void:
	for child: Node in get_children():
		if child is Area2D and child.name.begins_with("BlastZone"):
			var zone: Area2D = child as Area2D
			zone.body_entered.connect(_on_blast_zone_entered)
			_blast_zones.append(zone)

func get_spawn_position(index: int) -> Vector2:
	if spawn_points.is_empty() or index >= spawn_points.size():
		return Vector2.ZERO
	var node: Node = get_node(spawn_points[index])
	if node is Node2D:
		return (node as Node2D).global_position
	return Vector2.ZERO

func _on_blast_zone_entered(body: Node2D) -> void:
	if body is CharacterBase:
		(body as CharacterBase).eliminated.emit(body as CharacterBase)
