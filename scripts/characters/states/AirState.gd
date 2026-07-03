class_name AirState
extends CharacterState

func enter() -> void:
	character.play_animation(&"fall")

func physics_update(_delta: float) -> void:
	var dir: float = character.get_move_input()
	character.apply_horizontal_move(dir)
	if character.is_on_floor():
		character.jumps_remaining = character.stats.max_jumps
		machine.transition_to(&"Idle")
	elif character.is_jump_just_pressed() and character.jumps_remaining > 0:
		machine.transition_to(&"Jump")
	elif character.is_attack_just_pressed():
		machine.transition_to(&"AirAttack")
