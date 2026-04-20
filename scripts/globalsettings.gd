extends Node

var master_volume: float = 100.0
var music_volume: float = 100.0

func _ready() -> void:
	_apply_bus("Master", master_volume)
	_apply_bus("Music", music_volume)

func set_master_volume(v: float) -> void:
	master_volume = v
	_apply_bus("Master", v)

func set_music_volume(v: float) -> void:
	music_volume = v
	_apply_bus("Music", v)

func _apply_bus(bus_name: String, volume_0_100: float) -> void:
	var id = AudioServer.get_bus_index(bus_name)
	if id == -1:
		return
	var linear = max(volume_0_100 / 100.0, 0.0001)
	AudioServer.set_bus_volume_db(id, linear_to_db(linear))
