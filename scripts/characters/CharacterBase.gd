class_name CharacterBase
extends CharacterBody2D

signal eliminated(character: CharacterBase)
signal hp_changed(new_hp: float, max_hp: float)

@export var stats: CharacterStats
@export var ground_attack: AttackData
@export var air_attack: AttackData
## Optional per-character sprite sheets. When assigned and fully valid, the character
## renders from an AnimatedSprite2D instead of the procedural polygon; otherwise it falls
## back to the ProceduralAnimator path.
@export var sprite_set: CharacterSpriteSet

## Player slot (0-based). Drives spawn ordering, indicator color, and — for
## local (non-networked) play — which p#_ input action set controls this body.
var player_index: int = 0
## Peer id that provides input for this character. Defaults to the server (1),
## which covers local play. Set per-peer when spawned over the network.
var input_authority: int = 1

var current_hp: float = 0.0
var jumps_remaining: int = 0
var state_machine: CharacterStateMachine
var hitbox: HitboxComponent
var hurtbox: HurtboxComponent
var animation_player: AnimationPlayer
var animated_sprite: AnimatedSprite2D
var upgrade_manager: UpgradeManager

## Current-state key mirrored for MultiplayerSynchronizer. Written by the
## simulating peer each frame; on remote peers the setter drives visuals.
var synced_state: StringName = &"Idle":
	set(value):
		synced_state = value
		if not _is_sim_authority():
			_apply_remote_state(value)

var _facing: float = 1.0
## True once a sprite set builds successfully; routes play_animation/is_action_playing to
## the AnimatedSprite2D instead of the procedural AnimationPlayer.
var _uses_sprite_frames: bool = false
## Held-input the simulating peer reads this frame; the previous frame's copy is
## used to derive just-pressed edges.
var _input: InputData = InputData.new()
var _prev_input: InputData = InputData.new()
## Scratch buffer used by the input owner to sample local controls.
var _local_input: InputData = InputData.new()
var _jump_just_pressed: bool = false
var _attack_just_pressed: bool = false

var _action_left: StringName
var _action_right: StringName
var _action_jump: StringName
var _action_attack: StringName

const GRAVITY: float = 980.0
const _PLAYER_COLORS: Array[Color] = [
	Color(0.2, 0.4, 1.0),
	Color(1.0, 0.2, 0.2),
	Color(1.0, 0.55, 0.1),
	Color(0.65, 0.1, 1.0),
]

func _ready() -> void:
	stats = stats.duplicate() as CharacterStats
	_cache_input_actions()
	current_hp = stats.max_hp
	jumps_remaining = stats.max_jumps
	hitbox = $HitboxComponent as HitboxComponent
	hurtbox = $HurtboxComponent as HurtboxComponent
	animation_player = $AnimationPlayer as AnimationPlayer
	upgrade_manager = $UpgradeManager as UpgradeManager
	_setup_sprite_frames()
	hurtbox.hit_received.connect(_on_hit_received)
	_setup_state_machine()
	state_machine.start(&"Idle")
	var indicator: Polygon2D = $PlayerIndicator as Polygon2D
	indicator.color = _PLAYER_COLORS[clampi(player_index, 0, _PLAYER_COLORS.size() - 1)]

func _cache_input_actions() -> void:
	# Local play maps each player to its own p#_ action set. In networked play
	# every peer drives its own character from the shared p1_ controls.
	var idx: int = player_index
	if multiplayer.has_multiplayer_peer():
		idx = 0
	var p: int = idx + 1
	_action_left   = "p%d_left"   % p
	_action_right  = "p%d_right"  % p
	_action_jump   = "p%d_jump"   % p
	_action_attack = "p%d_attack" % p

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

func _physics_process(delta: float) -> void:
	if _is_input_owner():
		_sample_local_input()
		if _is_sim_authority():
			_input.copy_from(_local_input)
		else:
			# Client: hand the held state to the authoritative server.
			_receive_input.rpc_id(1, _local_input.move_axis, _local_input.jump_held, _local_input.attack_held)

	if not _is_sim_authority():
		# Remote peers only display state pushed by the synchronizer.
		return

	_jump_just_pressed = _input.jump_held and not _prev_input.jump_held
	_attack_just_pressed = _input.attack_held and not _prev_input.attack_held

	if not is_on_floor():
		velocity.y += GRAVITY * stats.gravity_scale * delta
	state_machine.physics_update(delta)
	move_and_slide()

	_prev_input.copy_from(_input)
	if _facing != 0.0:
		_apply_facing(_facing)
	synced_state = state_machine.current_state_name

func _sample_local_input() -> void:
	_local_input.move_axis = Input.get_axis(_action_left, _action_right)
	_local_input.jump_held = Input.is_action_pressed(_action_jump)
	_local_input.attack_held = Input.is_action_pressed(_action_attack)

## Runs on the server. Clients push their held input here each frame.
@rpc("any_peer", "call_remote", "unreliable_ordered")
func _receive_input(move_axis: float, jump_held: bool, attack_held: bool) -> void:
	if multiplayer.get_remote_sender_id() != input_authority:
		return
	_input.move_axis = move_axis
	_input.jump_held = jump_held
	_input.attack_held = attack_held

func _is_sim_authority() -> bool:
	return NetworkManager.is_host()

func _is_input_owner() -> bool:
	if not multiplayer.has_multiplayer_peer():
		return true
	return multiplayer.get_unique_id() == input_authority

## On remote peers, follow the authoritative state so animations track the sim.
func _apply_remote_state(state_name: StringName) -> void:
	if state_machine == null:
		return
	if state_machine.current_state_name == state_name:
		return
	state_machine.transition_to(state_name)

func get_move_input() -> float:
	var dir: float = _input.move_axis
	if dir != 0.0:
		_facing = sign(dir)
	return dir

func apply_horizontal_move(dir: float) -> void:
	velocity.x = dir * stats.move_speed

func is_jump_just_pressed() -> bool:
	return _jump_just_pressed

func is_attack_just_pressed() -> bool:
	return _attack_just_pressed

func get_current_attack_data() -> AttackData:
	if is_on_floor():
		return ground_attack
	return air_attack

## Caches the AnimatedSprite2D and, when a valid sprite set is assigned, builds its frames
## and switches the character over to sprite rendering. Any failure leaves the procedural
## polygon path intact (all-or-nothing fallback).
func _setup_sprite_frames() -> void:
	animated_sprite = $Sprite as AnimatedSprite2D
	if sprite_set == null:
		return
	var frames: SpriteFrames = SpriteFramesBuilder.build(sprite_set)
	if frames == null:
		return
	animated_sprite.sprite_frames = frames
	animated_sprite.visible = true
	_uses_sprite_frames = true
	var visual: CanvasItem = get_node_or_null(^"Visual") as CanvasItem
	if visual:
		visual.hide()

func play_animation(anim_name: StringName) -> void:
	if _uses_sprite_frames:
		if animated_sprite.sprite_frames.has_animation(anim_name):
			animated_sprite.play(anim_name)
		return
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

## Whether the current action clip is still playing. Backs the attack states' completion
## check across both the sprite and procedural animators.
func is_action_playing() -> bool:
	if _uses_sprite_frames:
		return animated_sprite.is_playing()
	return animation_player.is_playing()

## Faces the character left/right. Sprite characters flip the AnimatedSprite2D locally;
## flipping the whole body via scale.x is unstable (Godot re-decomposes a negative scale on
## a physics body into a rotation, which makes an asymmetric sprite spaz and stick). The
## procedural polygon is symmetric, so it keeps the original body-scale flip.
func _apply_facing(facing: float) -> void:
	if _uses_sprite_frames:
		animated_sprite.flip_h = facing < 0.0
	else:
		scale.x = facing

func take_damage_from(attack_data: AttackData, attacker: CharacterBase) -> void:
	GameState.combat_resolver.resolve_hit(self, attack_data, attacker)

func _on_hit_received(attack_data: AttackData, attacker: CharacterBase) -> void:
	take_damage_from(attack_data, attacker)
	if current_hp <= 0.0:
		eliminated.emit(self)
