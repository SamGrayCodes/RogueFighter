class_name MainMenu
extends Control

## Root of the game-flow. Local play routes through character/stage select;
## online routes through the network lobby. Rules can be tuned in place via the
## shared RulesEditor overlay before starting.

const CHARACTER_SELECT_SCENE: String = "res://scenes/ui/CharacterSelect.tscn"
const LOBBY_SCENE: String = "res://scenes/ui/LobbyScreen.tscn"
const RULES_EDITOR_SCENE: String = "res://scenes/ui/RulesEditor.tscn"

func _ready() -> void:
	# Returning here always means we are out of any netgame.
	if NetworkManager.is_networked():
		NetworkManager.leave()
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
	vbox.custom_minimum_size = Vector2(320, 0)
	vbox.add_theme_constant_override("separation", 14)
	center.add_child(vbox)

	var title: Label = Label.new()
	title.text = "ROGUEFIGHTER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	vbox.add_child(_menu_button("LOCAL PLAY", _on_local_pressed))
	vbox.add_child(_menu_button("ONLINE", _on_online_pressed))
	vbox.add_child(_menu_button("RULES", _on_rules_pressed))
	vbox.add_child(_menu_button("QUIT", _on_quit_pressed))

func _menu_button(label: String, handler: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = label
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(handler)
	return btn

func _on_local_pressed() -> void:
	NetworkManager.use_local()
	get_tree().change_scene_to_file(CHARACTER_SELECT_SCENE)

func _on_online_pressed() -> void:
	get_tree().change_scene_to_file(LOBBY_SCENE)

func _on_rules_pressed() -> void:
	var editor_scene: PackedScene = load(RULES_EDITOR_SCENE) as PackedScene
	var editor: RulesEditor = editor_scene.instantiate() as RulesEditor
	add_child(editor)
	editor.rules_applied.connect(func() -> void: editor.queue_free(), CONNECT_ONE_SHOT)
	editor.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
