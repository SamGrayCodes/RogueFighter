class_name InputData
extends RefCounted

## Per-frame player input snapshot.
##
## Carries *held* button states (not edge events) so it can be sampled on the
## owning peer, sent to the authoritative server, and replayed there. Edge
## events (just-pressed) are derived by comparing consecutive snapshots on the
## simulating peer — see CharacterBase.

var move_axis: float = 0.0
var jump_held: bool = false
var attack_held: bool = false

func copy_from(other: InputData) -> void:
	move_axis = other.move_axis
	jump_held = other.jump_held
	attack_held = other.attack_held

func clone() -> InputData:
	var out: InputData = InputData.new()
	out.copy_from(self)
	return out

func clear() -> void:
	move_axis = 0.0
	jump_held = false
	attack_held = false
