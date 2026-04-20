extends Control

@onready var start_button: Button = $StartButton
@onready var exit_button: Button = $ExitButton
@onready var settings_button: Button = $SettingsButton
@onready var settings_bg: Panel = $SettingsBG

func _ready() -> void:
	get_tree().paused = false
	start_button.visible = true
	exit_button.visible = true
	settings_button.visible = true
	settings_bg.visible = false
	settings_bg.closed.connect(_on_settings_closed)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/demo/FeelShowcase.tscn")

func _on_settings_button_pressed() -> void:
	start_button.visible = false
	exit_button.visible = false
	settings_button.visible = false
	settings_bg.visible = true

func _on_settings_closed() -> void:
	start_button.visible = true
	exit_button.visible = true
	settings_button.visible = true
	settings_bg.visible = false
