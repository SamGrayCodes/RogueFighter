class_name JumpState
extends CharacterState

func enter() -> void:
	character.jumps_remaining -= 1
	character.velocity.y = character.stats.jump_velocity
	character.play_animation(&"jump")

func physics_update(_delta: float) -> void:
	var dir: float = character.get_move_input()
	character.apply_horizontal_move(dir)
	if character.velocity.y >= 0.0:
		machine.transition_to(&"Air")
	elif character.is_attack_just_pressed():
		machine.transition_to(&"AirAttack")
	elif character.is_jump_just_pressed() and character.jumps_remaining > 0:
		machine.transition_to(&"Jump")
