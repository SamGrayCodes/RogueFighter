class_name RulesEditor
extends CanvasLayer

signal rules_applied

var _rules: GameRules
var _slot_name_input: LineEdit
var _load_option: OptionButton

func _ready() -> void:
	_rules = GameState.active_rules.duplicate() as GameRules
	_build_ui()

func _build_ui() -> void:
	for child: Node in get_children():
		child.queue_free()

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 0.95)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var outer: MarginContainer = MarginContainer.new()
	outer.add_theme_constant_override("margin_top", 40)
	outer.add_theme_constant_override("margin_left", 120)
	outer.add_theme_constant_override("margin_right", 120)
	outer.add_theme_constant_override("margin_bottom", 40)
	scroll.add_child(outer)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	outer.add_child(vbox)

	var title: Label = Label.new()
	title.text = "GAME RULES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	_add_grid_row(grid, "Mode", _build_mode_option())
	_add_grid_row(grid, "Rounds", _build_rounds_option())
	_add_grid_row(grid, "Time Limit", _build_time_option())
	_add_grid_row(grid, "Starting HP", _build_hp_option())
	_add_grid_row(grid, "Damage Scaling", _build_damage_option())
	_add_grid_row(grid, "Upgrade Offers / Round", _build_offers_option())

	vbox.add_child(HSeparator.new())

	var bl_label: Label = Label.new()
	bl_label.text = "UPGRADE BLACKLIST"
	bl_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(bl_label)

	var bl_grid: GridContainer = GridContainer.new()
	bl_grid.columns = 4
	bl_grid.add_theme_constant_override("h_separation", 8)
	bl_grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(bl_grid)

	for upgrade: UpgradeData in UpgradeRegistry.all_upgrades:
		var btn: Button = Button.new()
		btn.text = upgrade.display_name
		btn.toggle_mode = true
		btn.button_pressed = _rules.blacklisted_upgrades.has(upgrade.id)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.toggled.connect(_on_blacklist_toggled.bind(upgrade.id))
		bl_grid.add_child(btn)

	vbox.add_child(HSeparator.new())

	var save_row: HBoxContainer = HBoxContainer.new()
	save_row.add_theme_constant_override("separation", 8)
	vbox.add_child(save_row)

	var save_lbl: Label = Label.new()
	save_lbl.text = "Save As:"
	save_row.add_child(save_lbl)

	_slot_name_input = LineEdit.new()
	_slot_name_input.text = "custom"
	_slot_name_input.placeholder_text = "preset name"
	_slot_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_row.add_child(_slot_name_input)

	var save_btn: Button = Button.new()
	save_btn.text = "Save"
	save_btn.pressed.connect(_on_save_pressed)
	save_row.add_child(save_btn)

	var load_row: HBoxContainer = HBoxContainer.new()
	load_row.add_theme_constant_override("separation", 8)
	vbox.add_child(load_row)

	var load_lbl: Label = Label.new()
	load_lbl.text = "Load:"
	load_row.add_child(load_lbl)

	_load_option = OptionButton.new()
	_load_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refresh_load_options()
	load_row.add_child(_load_option)

	var load_btn: Button = Button.new()
	load_btn.text = "Load"
	load_btn.pressed.connect(_on_load_pressed)
	load_row.add_child(load_btn)

	vbox.add_child(HSeparator.new())

	var start_btn: Button = Button.new()
	start_btn.text = "START MATCH"
	start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_btn.pressed.connect(_on_start_pressed)
	vbox.add_child(start_btn)


func _add_grid_row(grid: GridContainer, label_text: String, control: Control) -> void:
	var lbl: Label = Label.new()
	lbl.text = label_text
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	grid.add_child(lbl)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(control)


func _build_mode_option() -> OptionButton:
	var opt: OptionButton = OptionButton.new()
	var ids: Array[StringName] = [&"standard", &"no_upgrades", &"sudden_death"]
	var labels: Array[String] = ["Standard", "No Upgrades", "Sudden Death"]
	for lbl: String in labels:
		opt.add_item(lbl)
	for i: int in ids.size():
		if ids[i] == _rules.game_mode_id:
			opt.selected = i
			break
	opt.item_selected.connect(func(index: int) -> void: _rules.game_mode_id = ids[index])
	return opt


func _build_rounds_option() -> OptionButton:
	var opt: OptionButton = OptionButton.new()
	var vals: Array[int] = [1, 3, 5]
	for v: int in vals:
		opt.add_item("%d" % v)
	for i: int in vals.size():
		if vals[i] == _rules.round_count:
			opt.selected = i
			break
	opt.item_selected.connect(func(index: int) -> void: _rules.round_count = vals[index])
	return opt


func _build_time_option() -> OptionButton:
	var opt: OptionButton = OptionButton.new()
	var vals: Array[float] = [30.0, 60.0, 90.0, -1.0]
	var labels: Array[String] = ["30s", "60s", "90s", "No Limit"]
	for lbl: String in labels:
		opt.add_item(lbl)
	for i: int in vals.size():
		if is_equal_approx(vals[i], _rules.round_time_limit):
			opt.selected = i
			break
	opt.item_selected.connect(func(index: int) -> void: _rules.round_time_limit = vals[index])
	return opt


func _build_hp_option() -> OptionButton:
	var opt: OptionButton = OptionButton.new()
	var vals: Array[float] = [50.0, 100.0, 150.0, 200.0]
	for v: float in vals:
		opt.add_item("%d HP" % int(v))
	for i: int in vals.size():
		if is_equal_approx(vals[i], _rules.starting_hp):
			opt.selected = i
			break
	opt.item_selected.connect(func(index: int) -> void: _rules.starting_hp = vals[index])
	return opt


func _build_damage_option() -> OptionButton:
	var opt: OptionButton = OptionButton.new()
	var vals: Array[float] = [0.5, 1.0, 1.5, 2.0]
	var labels: Array[String] = ["0.5x", "1x", "1.5x", "2x"]
	for lbl: String in labels:
		opt.add_item(lbl)
	for i: int in vals.size():
		if is_equal_approx(vals[i], _rules.damage_scaling):
			opt.selected = i
			break
	opt.item_selected.connect(func(index: int) -> void: _rules.damage_scaling = vals[index])
	return opt


func _build_offers_option() -> OptionButton:
	var opt: OptionButton = OptionButton.new()
	var vals: Array[int] = [1, 2, 3, 4]
	for v: int in vals:
		opt.add_item("%d" % v)
	for i: int in vals.size():
		if vals[i] == _rules.upgrade_offers_per_round:
			opt.selected = i
			break
	opt.item_selected.connect(func(index: int) -> void: _rules.upgrade_offers_per_round = vals[index])
	return opt


func _refresh_load_options() -> void:
	if _load_option == null:
		return
	_load_option.clear()
	_load_option.add_item("(select preset)")
	for slot: String in RulesSerializer.list_saved():
		_load_option.add_item(slot)


func _on_blacklist_toggled(pressed: bool, id: StringName) -> void:
	if pressed:
		if not _rules.blacklisted_upgrades.has(id):
			_rules.blacklisted_upgrades.append(id)
	else:
		_rules.blacklisted_upgrades.erase(id)


func _on_save_pressed() -> void:
	var slot: String = _slot_name_input.text.strip_edges()
	if slot.is_empty():
		return
	RulesSerializer.save(_rules, slot)
	_refresh_load_options()


func _on_load_pressed() -> void:
	var index: int = _load_option.selected
	if index <= 0:
		return
	var slot: String = _load_option.get_item_text(index)
	var loaded: GameRules = RulesSerializer.load_slot(slot)
	if loaded == null:
		return
	_rules = loaded
	_build_ui()


func _on_start_pressed() -> void:
	GameState.active_rules = _rules
	GameState.active_mode = GameState.get_mode_for_id(_rules.game_mode_id)
	rules_applied.emit()
	hide()
