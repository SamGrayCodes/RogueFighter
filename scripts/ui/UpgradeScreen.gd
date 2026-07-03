class_name UpgradeScreen
extends CanvasLayer

signal selections_complete

var _characters: Array[CharacterBase] = []
var _selections_remaining: int = 0
var _player_locked: Array[bool] = []

func show_for_characters(characters: Array[CharacterBase]) -> void:
	_characters = characters
	_selections_remaining = characters.size()
	_player_locked.resize(characters.size())
	_player_locked.fill(false)
	_build_ui()
	show()

func _build_ui() -> void:
	for child: Node in get_children():
		child.queue_free()

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.82)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 24)
	add_child(root)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(margin)

	var inner: VBoxContainer = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 24)
	margin.add_child(inner)

	var title: Label = Label.new()
	title.text = "CHOOSE YOUR UPGRADE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(title)

	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	inner.add_child(row)

	for i: int in _characters.size():
		var applied_ids: Array[StringName] = []
		for ud: UpgradeData in _characters[i].upgrade_manager.applied_upgrades:
			applied_ids.append(ud.id)
		var combined_exclude: Array[StringName] = applied_ids + GameState.active_rules.blacklisted_upgrades
		var offers: Array[UpgradeData] = UpgradeRegistry.get_random_offers(
			GameState.active_rules.upgrade_offers_per_round, combined_exclude
		)
		row.add_child(_build_player_panel(i, _characters[i], offers))

func _build_player_panel(slot: int, character: CharacterBase, offers: Array[UpgradeData]) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var header: Label = Label.new()
	header.text = "PLAYER %d" % (character.player_index + 1)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	if offers.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No upgrades available."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_label)
		_on_card_selected(slot, character, null, vbox)
		return panel

	for offer: UpgradeData in offers:
		var btn: Button = Button.new()
		btn.text = "%s\n%s" % [offer.display_name, offer.description]
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_card_selected.bind(slot, character, offer, vbox))
		vbox.add_child(btn)

	return panel

func _on_card_selected(slot: int, character: CharacterBase, upgrade: UpgradeData, panel: VBoxContainer) -> void:
	if _player_locked[slot]:
		return
	_player_locked[slot] = true

	if upgrade != null:
		character.upgrade_manager.add_upgrade(upgrade)

	for child: Node in panel.get_children():
		if child is Button:
			(child as Button).disabled = true

	var confirm: Label = Label.new()
	confirm.text = "✓  %s" % (upgrade.display_name if upgrade != null else "None")
	confirm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(confirm)

	_selections_remaining -= 1
	if _selections_remaining == 0:
		await get_tree().create_timer(0.8).timeout
		selections_complete.emit()
		hide()
