extends Panel

signal closed
signal home_requested

@onready var home_button: Button = $HomeButton  # adjust path
@onready var done_button: Button = $DoneButton  # if you have one

func _ready() -> void:
	home_button.pressed.connect(_on_home_pressed)
	home_button.hide()
	done_button.pressed.connect(_on_done_pressed)
	$ScrollContainer/VBoxContainer/AAContainer/AADropdown.selected = Settings.anti_aliasing

func show_home_button(show: bool) -> void:
	home_button.visible = show

func _on_home_pressed() -> void:
	home_requested.emit()

func _on_done_pressed() -> void:
	hide()
	closed.emit()

func _on_aa_dropdown_item_selected(index: int) -> void:
	Settings.set_anti_aliasing(index)


func _on_upscaler_dropdown_item_selected(index: int) -> void:
	pass # Replace with function body.


func _on_resolution_scale_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_ssao_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_bloom_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_volumetric_fog_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_sdfgi_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
