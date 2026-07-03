class_name CharacterState
extends RefCounted

var character: CharacterBase
var machine: CharacterStateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
