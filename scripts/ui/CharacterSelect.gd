class_name CharacterSelect
extends Control

## Local play: choose how many players (2-4) and each one's fighter, then move
## on to stage select. Writes the chosen roster into GameState.players.

const STAGE_SELECT_SCENE: String = "res://scenes/ui/StageSelect.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/ui/MainMenu.tscn"
const MAX_PLAYERS: int = 4

var _player_count: int = 2
var _picks: Array[StringName] = []
var _rows: VBoxContainer

func _ready() -> void:
	_picks.resize(MAX_PLAYERS)
	var catalog_size: int = GameState.character_catalog.size()
	for i: int in MAX_PLAYERS:
		var entry: GameState.ContentEntry = GameState.character_catalog[i % catalog_size]
		_picks[i] = entry.id
	_build_ui()

func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(460, 0)
	vbox.add_theme_constant_override("separation", 14)
	center.add_child(vbox)

	var title: Label = Label.new()
	title.text = "SELECT FIGHTERS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var count_row: HBoxContainer = HBoxContainer.new()
	count_row.add_theme_constant_override("separation", 8)
	var count_label: Label = Label.new()
	count_label.text = "Players"
	count_label.custom_minimum_size = Vector2(90, 0)
	count_row.add_child(count_label)
	var count_option: OptionButton = OptionButton.new()
	count_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for n: int in [2, 3, 4]:
		count_option.add_item("%d Players" % n)
	count_option.selected = _player_count - 2
	count_option.item_selected.connect(_on_count_selected)
	count_row.add_child(count_option)
	vbox.add_child(count_row)

	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 8)
	vbox.add_child(_rows)
	_rebuild_rows()

	vbox.add_child(HSeparator.new())

	var nav: HBoxContainer = HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	vbox.add_child(nav)

	var back_btn: Button = Button.new()
	back_btn.text = "BACK"
	back_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_btn.pressed.connect(_on_back_pressed)
	nav.add_child(back_btn)

	var next_btn: Button = Button.new()
	next_btn.text = "NEXT"
	next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_btn.pressed.connect(_on_next_pressed)
	nav.add_child(next_btn)

func _rebuild_rows() -> void:
	for child: Node in _rows.get_children():
		child.queue_free()
	for i: int in _player_count:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var label: Label = Label.new()
		label.text = "Player %d" % (i + 1)
		label.custom_minimum_size = Vector2(90, 0)
		label.add_theme_color_override("font_color", HUD.PLAYER_COLORS[i])
		row.add_child(label)

		var option: OptionButton = OptionButton.new()
		option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for entry: GameState.ContentEntry in GameState.character_catalog:
			option.add_item(entry.display_name)
		option.selected = GameState.get_character_index(_picks[i])
		option.item_selected.connect(_on_character_selected.bind(i))
		row.add_child(option)

		_rows.add_child(row)

func _on_count_selected(index: int) -> void:
	_player_count = index + 2
	_rebuild_rows()

func _on_character_selected(index: int, slot: int) -> void:
	var entry: GameState.ContentEntry = GameState.character_catalog[index]
	_picks[slot] = entry.id

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_next_pressed() -> void:
	GameState.clear_players()
	for i: int in _player_count:
		GameState.add_player(i, _picks[i], true, 1)
	get_tree().change_scene_to_file(STAGE_SELECT_SCENE)
