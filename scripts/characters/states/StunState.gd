class_name StunState
extends CharacterState

var _duration: float = 0.0
var _elapsed: float = 0.0

func enter() -> void:
	_elapsed = 0.0
	character.play_animation(&"stun")

func set_duration(duration: float) -> void:
	_duration = duration

func physics_update(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		if character.is_on_floor():
			machine.transition_to(&"Idle")
		else:
			machine.transition_to(&"Air")
