class_name KnockbackState
extends CharacterState

const DRAG: float = 0.85

func enter() -> void:
	character.play_animation(&"knockback")

func physics_update(_delta: float) -> void:
	character.velocity.x *= DRAG
	if character.is_on_floor() and abs(character.velocity.x) < 20.0:
		character.jumps_remaining = character.stats.max_jumps
		machine.transition_to(&"Idle")
