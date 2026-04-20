extends Control

const GAME_SCENE: String = "res://scenes/menu.tscn"

@onready var start_button: Button = $StartButton
@onready var settings_button: Button = $SettingsButton

func _ready() -> void:
	get_tree().paused = false

func _on_exit_button_pressed() -> void:
	get_tree().quit() # Replace with function body.


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/demo/FeelShowcase.tscn")
