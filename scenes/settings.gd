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
	$ScrollContainer/VBoxContainer/UpscalerContainer/UpscalerDropdown.selected = Settings.upscaler
	$ScrollContainer/VBoxContainer/ResolutionScaleContainer/ResolutionScaleSlider.value = Settings.render_scale
	$ScrollContainer/VBoxContainer/SSAOContainer/SSAOCheckButton.button_pressed = Settings.ssao_enabled
	$ScrollContainer/VBoxContainer/BloomContainer/BloomCheckButton.button_pressed = Settings.bloom_enabled
	$ScrollContainer/VBoxContainer/VolumetricFogContainer/VolumetricFogCheckButton.button_pressed = Settings.volumetric_fog_enabled
	$ScrollContainer/VBoxContainer/SDFGIContainer/SDFGICheckButton.button_pressed = Settings.sdfgi_enabled

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
	Settings.set_upscaler(index)


func _on_resolution_scale_slider_value_changed(value: float) -> void:
	Settings.set_render_scale(value)


func _on_ssao_check_button_toggled(toggled_on: bool) -> void:
	Settings.set_ssao_enabled(toggled_on)


func _on_bloom_check_button_toggled(toggled_on: bool) -> void:
	Settings.set_bloom_enabled(toggled_on)


func _on_volumetric_fog_check_button_toggled(toggled_on: bool) -> void:
	Settings.set_volumetric_fog_enabled(toggled_on)


func _on_sdfgi_check_button_toggled(toggled_on: bool) -> void:
	Settings.set_sdfgi_enabled(toggled_on)
