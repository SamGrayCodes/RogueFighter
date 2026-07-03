class_name IdleState
extends CharacterState

func enter() -> void:
	character.velocity.x = 0.0
	character.play_animation(&"idle")

func physics_update(_delta: float) -> void:
	if not character.is_on_floor():
		machine.transition_to(&"Air")
		return
	var dir: float = character.get_move_input()
	if dir != 0.0:
		machine.transition_to(&"Run")
	elif character.is_jump_just_pressed():
		machine.transition_to(&"Jump")
	elif character.is_attack_just_pressed():
		machine.transition_to(&"Attack")
