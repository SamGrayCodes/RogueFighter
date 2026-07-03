class_name HUD
extends CanvasLayer

## In-match overlay: a HP bar per player, the round counter, and the round
## timer. HP values are polled from each character every frame (they are kept
## correct on remote peers by the character's MultiplayerSynchronizer).

const PLAYER_COLORS: Array[Color] = [
	Color(0.2, 0.4, 1.0),
	Color(1.0, 0.2, 0.2),
	Color(1.0, 0.55, 0.1),
	Color(0.65, 0.1, 1.0),
]

var _characters: Array[CharacterBase] = []
var _bars: Array[ProgressBar] = []
var _win_labels: Array[Label] = []
var _max_hps: Array[float] = []

var _player_row: HBoxContainer
var _round_label: Label
var _timer_label: Label

func _ready() -> void:
	_build_static_ui()

func _build_static_ui() -> void:
	var top: MarginContainer = MarginContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.add_theme_constant_override("margin_top", 16)
	top.add_theme_constant_override("margin_left", 24)
	top.add_theme_constant_override("margin_right", 24)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)

	_player_row = HBoxContainer.new()
	_player_row.add_theme_constant_override("separation", 24)
	_player_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_player_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_player_row)

	var center: VBoxContainer = VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	center.add_theme_constant_override("separation", 2)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_round_label = Label.new()
	_round_label.text = ""
	_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_round_label)

	_timer_label = Label.new()
	_timer_label.text = ""
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_timer_label)

## Rebuild the per-player HP panels. Call after characters are spawned/reset.
func setup(characters: Array[CharacterBase]) -> void:
	_characters = characters
	_bars.clear()
	_win_labels.clear()
	_max_hps.clear()
	for child: Node in _player_row.get_children():
		child.queue_free()

	for character: CharacterBase in characters:
		var color: Color = PLAYER_COLORS[clampi(character.player_index, 0, PLAYER_COLORS.size() - 1)]

		var panel: VBoxContainer = VBoxContainer.new()
		panel.custom_minimum_size = Vector2(190, 0)
		panel.add_theme_constant_override("separation", 4)

		var name_label: Label = Label.new()
		name_label.text = "P%d · %s" % [character.player_index + 1, character.stats.display_name]
		name_label.add_theme_color_override("font_color", color)
		panel.add_child(name_label)

		var bar: ProgressBar = ProgressBar.new()
		bar.min_value = 0.0
		bar.max_value = maxf(character.current_hp, 1.0)
		bar.value = character.current_hp
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 18)
		bar.add_theme_color_override("font_color", color)
		panel.add_child(bar)

		var wins: Label = Label.new()
		wins.text = ""
		panel.add_child(wins)

		_player_row.add_child(panel)
		_bars.append(bar)
		_win_labels.append(wins)
		_max_hps.append(maxf(character.current_hp, 1.0))

func set_round(round_number: int) -> void:
	_round_label.text = "ROUND %d" % round_number

func set_timer(seconds: float) -> void:
	if seconds <= 0.0:
		_timer_label.text = "∞"
		return
	_timer_label.text = "%d" % ceili(seconds)

func _process(_delta: float) -> void:
	for i: int in _characters.size():
		if i >= _bars.size():
			break
		var character: CharacterBase = _characters[i]
		var hp: float = maxf(character.current_hp, 0.0)
		if hp > _max_hps[i]:
			_max_hps[i] = hp
		_bars[i].max_value = _max_hps[i]
		_bars[i].value = hp
		_bars[i].modulate = Color(1, 1, 1, 1) if character.visible else Color(1, 1, 1, 0.35)
		_win_labels[i].text = "Wins: %d" % _wins_for(character.player_index)

func _wins_for(player_index: int) -> int:
	for pd: GameState.PlayerData in GameState.players:
		if pd.player_index == player_index:
			return pd.round_wins
	return 0
