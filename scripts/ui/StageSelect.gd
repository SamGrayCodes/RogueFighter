class_name StageSelect
extends Control

## Local play: pick a stage, then launch the match. The roster was already set
## in CharacterSelect; here we only record the stage and reset the round count.

const GAME_WORLD_SCENE: String = "res://scenes/game/GameWorld.tscn"
const CHARACTER_SELECT_SCENE: String = "res://scenes/ui/CharacterSelect.tscn"

var _selected_index: int = 0

func _ready() -> void:
	_selected_index = GameState.get_stage_index(GameState.selected_stage_id)
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
	vbox.custom_minimum_size = Vector2(420, 0)
	vbox.add_theme_constant_override("separation", 14)
	center.add_child(vbox)

	var title: Label = Label.new()
	title.text = "SELECT STAGE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var stage_option: OptionButton = OptionButton.new()
	stage_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for entry: GameState.ContentEntry in GameState.stage_catalog:
		stage_option.add_item(entry.display_name)
	stage_option.selected = _selected_index
	stage_option.item_selected.connect(_on_stage_selected)
	vbox.add_child(stage_option)

	vbox.add_child(HSeparator.new())

	var nav: HBoxContainer = HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	vbox.add_child(nav)

	var back_btn: Button = Button.new()
	back_btn.text = "BACK"
	back_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_btn.pressed.connect(_on_back_pressed)
	nav.add_child(back_btn)

	var start_btn: Button = Button.new()
	start_btn.text = "START MATCH"
	start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_btn.pressed.connect(_on_start_pressed)
	nav.add_child(start_btn)

func _on_stage_selected(index: int) -> void:
	_selected_index = index

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(CHARACTER_SELECT_SCENE)

func _on_start_pressed() -> void:
	var entry: GameState.ContentEntry = GameState.stage_catalog[_selected_index]
	GameState.selected_stage_id = entry.id
	GameState.current_round = 0
	GameState.last_match_winner = -1
	get_tree().change_scene_to_file(GAME_WORLD_SCENE)
