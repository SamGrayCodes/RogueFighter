class_name RunState
extends CharacterState

func enter() -> void:
	character.play_animation(&"run")

func physics_update(_delta: float) -> void:
	if not character.is_on_floor():
		machine.transition_to(&"Air")
		return
	if character.is_jump_just_pressed():
		machine.transition_to(&"Jump")
		return
	if character.is_attack_just_pressed():
		machine.transition_to(&"Attack")
		return
	var dir: float = character.get_move_input()
	if dir == 0.0:
		machine.transition_to(&"Idle")
	else:
		character.apply_horizontal_move(dir)
