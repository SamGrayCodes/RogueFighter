class_name LobbyScreen
extends Control

## Pre-match network lobby. The host opens an ENet server; clients join by IP.
## Once peers are connected the host starts the match, which moves every peer
## into GameWorld via NetworkManager.

var _address_input: LineEdit
var _port_input: LineEdit
var _status_label: Label
var _roster_label: Label
var _host_button: Button
var _join_button: Button
var _start_button: Button

func _ready() -> void:
	_build_ui()
	NetworkManager.roster_changed.connect(_refresh_roster)
	NetworkManager.connection_succeeded.connect(_on_connection_succeeded)
	NetworkManager.connection_failed.connect(_on_connection_failed)

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
	title.text = "NETWORK LOBBY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var addr_row: HBoxContainer = _labeled_row("Address")
	_address_input = LineEdit.new()
	_address_input.text = "127.0.0.1"
	_address_input.placeholder_text = "host IP"
	_address_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	addr_row.add_child(_address_input)
	vbox.add_child(addr_row)

	var port_row: HBoxContainer = _labeled_row("Port")
	_port_input = LineEdit.new()
	_port_input.text = str(NetworkManager.DEFAULT_PORT)
	_port_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	port_row.add_child(_port_input)
	vbox.add_child(port_row)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	vbox.add_child(button_row)

	_host_button = Button.new()
	_host_button.text = "HOST"
	_host_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_host_button.pressed.connect(_on_host_pressed)
	button_row.add_child(_host_button)

	_join_button = Button.new()
	_join_button.text = "JOIN"
	_join_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_join_button.pressed.connect(_on_join_pressed)
	button_row.add_child(_join_button)

	vbox.add_child(HSeparator.new())

	_status_label = Label.new()
	_status_label.text = "Not connected."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_status_label)

	_roster_label = Label.new()
	_roster_label.text = ""
	_roster_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_roster_label)

	_start_button = Button.new()
	_start_button.text = "START MATCH"
	_start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_start_button.disabled = true
	_start_button.visible = false
	_start_button.pressed.connect(_on_start_pressed)
	vbox.add_child(_start_button)

func _labeled_row(label_text: String) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var lbl: Label = Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(80, 0)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)
	return row

func _parse_port() -> int:
	var text: String = _port_input.text.strip_edges()
	if text.is_valid_int():
		return text.to_int()
	return NetworkManager.DEFAULT_PORT

func _on_host_pressed() -> void:
	var err: Error = NetworkManager.host_game(_parse_port())
	if err != OK:
		_status_label.text = "Failed to host (error %d)." % err
		return
	_status_label.text = "Hosting on port %d. Waiting for players..." % _parse_port()
	_set_connection_controls_enabled(false)
	_start_button.visible = true
	_start_button.disabled = false
	_refresh_roster()

func _on_join_pressed() -> void:
	var address: String = _address_input.text.strip_edges()
	if address.is_empty():
		_status_label.text = "Enter a host address."
		return
	var err: Error = NetworkManager.join_game(address, _parse_port())
	if err != OK:
		_status_label.text = "Failed to join (error %d)." % err
		return
	_status_label.text = "Connecting to %s..." % address
	_set_connection_controls_enabled(false)

func _on_start_pressed() -> void:
	NetworkManager.start_match()

func _on_connection_succeeded() -> void:
	if not NetworkManager.is_host():
		_status_label.text = "Connected. Waiting for host to start..."
	_refresh_roster()

func _on_connection_failed(reason: String) -> void:
	_status_label.text = "Connection failed: %s" % reason
	_set_connection_controls_enabled(true)

func _set_connection_controls_enabled(enabled: bool) -> void:
	_host_button.disabled = not enabled
	_join_button.disabled = not enabled
	_address_input.editable = enabled
	_port_input.editable = enabled

func _refresh_roster() -> void:
	if not NetworkManager.is_networked():
		_roster_label.text = ""
		return
	var count: int = 1 + NetworkManager.connected_peers.size()
	var self_note: String = " (you)" if NetworkManager.is_host() else ""
	_roster_label.text = "Peers connected: %d / %d%s" % [count, NetworkManager.MAX_PLAYERS, self_note]
