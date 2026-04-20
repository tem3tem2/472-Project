extends HSlider

@export var bus_kind: String = "Master"  

func _ready() -> void:
	match bus_kind:
		"Master":
			value = Settings.master_volume
		"Music":
			value = Settings.music_volume
	value_changed.connect(_on_value_changed)

func _on_value_changed(v: float) -> void:
	match bus_kind:
		"Master":
			Settings.set_master_volume(v)
		"Music":
			Settings.set_music_volume(v)
