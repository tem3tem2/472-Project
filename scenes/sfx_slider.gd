extends HSlider
@export var bus_kind: String = "SFX"
func _ready() -> void:
	match bus_kind:
		"SFX":
			value = Settings.sfx_volume
	value_changed.connect(_on_value_changed)
func _on_value_changed(v: float) -> void:
	match bus_kind:
		"SFX":
			Settings.set_sfx_volume(v)
