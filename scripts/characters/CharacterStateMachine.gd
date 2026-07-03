class_name CharacterStateMachine
extends RefCounted

var current_state: CharacterState
var _states: Dictionary = {}

func register(state_name: StringName, state: CharacterState) -> void:
	_states[state_name] = state

func start(initial_state: StringName) -> void:
	current_state = _states[initial_state]
	current_state.enter()

func transition_to(state_name: StringName) -> void:
	if not _states.has(state_name):
		push_error("CharacterStateMachine: unknown state '%s'" % state_name)
		return
	current_state.exit()
	current_state = _states[state_name]
	current_state.enter()

func handle_input(event: InputEvent) -> void:
	current_state.handle_input(event)

func physics_update(delta: float) -> void:
	current_state.physics_update(delta)
