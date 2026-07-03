class_name ResultsScreen
extends Control

## Post-match summary. Reads the winner and per-player round wins from GameState.
## "Play Again" returns to fighter select (local only); "Main Menu" exits any
## active net session.

const MAIN_MENU_SCENE: String = "res://scenes/ui/MainMenu.tscn"
const CHARACTER_SELECT_SCENE: String = "res://scenes/ui/CharacterSelect.tscn"

func _ready() -> void:
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
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)

	var title: Label = Label.new()
	title.text = "RESULTS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var winner: Label = Label.new()
	winner.text = _winner_text()
	winner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if GameState.last_match_winner >= 0:
		winner.add_theme_color_override("font_color", HUD.PLAYER_COLORS[clampi(GameState.last_match_winner, 0, HUD.PLAYER_COLORS.size() - 1)])
	vbox.add_child(winner)

	vbox.add_child(HSeparator.new())

	for pd: GameState.PlayerData in GameState.players:
		var line: Label = Label.new()
		line.text = "P%d · %s — Wins: %d" % [pd.player_index + 1, GameState.get_character_name(pd.character_id), pd.round_wins]
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.add_theme_color_override("font_color", HUD.PLAYER_COLORS[clampi(pd.player_index, 0, HUD.PLAYER_COLORS.size() - 1)])
		vbox.add_child(line)

	vbox.add_child(HSeparator.new())

	var nav: HBoxContainer = HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	vbox.add_child(nav)

	if not NetworkManager.is_networked():
		var again_btn: Button = Button.new()
		again_btn.text = "PLAY AGAIN"
		again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		again_btn.pressed.connect(_on_play_again_pressed)
		nav.add_child(again_btn)

	var menu_btn: Button = Button.new()
	menu_btn.text = "MAIN MENU"
	menu_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_btn.pressed.connect(_on_main_menu_pressed)
	nav.add_child(menu_btn)

func _winner_text() -> String:
	if GameState.last_match_winner < 0:
		return "DRAW"
	return "PLAYER %d WINS!" % (GameState.last_match_winner + 1)

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(CHARACTER_SELECT_SCENE)

func _on_main_menu_pressed() -> void:
	# MainMenu._ready tears down any lingering network session.
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
