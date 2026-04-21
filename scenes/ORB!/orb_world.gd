extends Node3D

@onready var _settings_menu: Panel = $SettingsBG

func _ready() -> void:
	if _settings_menu:
		_settings_menu.hide()
		_settings_menu.closed.connect(_on_settings_closed)
		_settings_menu.home_requested.connect(_on_home_requested)
		_settings_menu.show_home_button(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _settings_menu.visible:
			_settings_menu.hide()
			_on_settings_closed()
		else:
			_open_settings()
		get_viewport().set_input_as_handled()

func _open_settings() -> void:
	_settings_menu.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_settings_closed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_home_requested() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
