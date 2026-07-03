class_name CharacterBase
extends CharacterBody2D

signal eliminated(character: CharacterBase)
signal hp_changed(new_hp: float, max_hp: float)

@export var stats: CharacterStats
@export var ground_attack: AttackData
@export var air_attack: AttackData

var player_index: int = 0
var current_hp: float = 0.0
var jumps_remaining: int = 0
var state_machine: CharacterStateMachine
var hitbox: HitboxComponent
var hurtbox: HurtboxComponent
var animation_player: AnimationPlayer

var _facing: float = 1.0
var _jump_pressed: bool = false
var _attack_pressed: bool = false

const GRAVITY: float = 980.0

func _ready() -> void:
	current_hp = stats.max_hp
	jumps_remaining = stats.max_jumps
	hitbox = $HitboxComponent as HitboxComponent
	hurtbox = $HurtboxComponent as HurtboxComponent
	animation_player = $AnimationPlayer as AnimationPlayer
	hurtbox.hit_received.connect(_on_hit_received)
	_setup_state_machine()
	state_machine.start(&"Idle")

func _setup_state_machine() -> void:
	state_machine = CharacterStateMachine.new()
	var states: Dictionary = {
		&"Idle": IdleState.new(),
		&"Run": RunState.new(),
		&"Jump": JumpState.new(),
		&"Air": AirState.new(),
		&"Attack": AttackState.new(),
		&"AirAttack": AirAttackState.new(),
		&"Stun": StunState.new(),
		&"Knockback": KnockbackState.new(),
	}
	for key: StringName in states:
		var state: CharacterState = states[key]
		state.character = self
		state.machine = state_machine
		state_machine.register(key, state)

func _unhandled_input(event: InputEvent) -> void:
	_jump_pressed = event.is_action_pressed("p%d_jump" % player_index)
	_attack_pressed = event.is_action_pressed("p%d_attack" % player_index)
	state_machine.handle_input(event)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * stats.gravity_scale * delta
	state_machine.physics_update(delta)
	move_and_slide()
	_jump_pressed = false
	_attack_pressed = false
	if _facing != 0.0:
		scale.x = _facing

func get_move_input() -> float:
	var dir: float = Input.get_axis("p%d_left" % player_index, "p%d_right" % player_index)
	if dir != 0.0:
		_facing = sign(dir)
	return dir

func apply_horizontal_move(dir: float) -> void:
	velocity.x = dir * stats.move_speed

func is_jump_just_pressed() -> bool:
	return _jump_pressed

func is_attack_just_pressed() -> bool:
	return _attack_pressed

func get_current_attack_data() -> AttackData:
	if is_on_floor():
		return ground_attack
	return air_attack

func play_animation(anim_name: StringName) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func take_damage_from(attack_data: AttackData, attacker: CharacterBase) -> void:
	GameState.combat_resolver.resolve_hit(self, attack_data, attacker)

func _on_hit_received(attack_data: AttackData, attacker: CharacterBase) -> void:
	take_damage_from(attack_data, attacker)
	if current_hp <= 0.0:
		eliminated.emit(self)
