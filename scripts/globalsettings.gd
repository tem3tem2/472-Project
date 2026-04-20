extends Node

const CONFIG_PATH := "user://settings.cfg"

var master_volume: float = 100.0
var music_volume: float = 100.0
var anti_aliasing: int = 0
var quality: int = 1 # 0 = Low, 1 = High

func _ready() -> void:
	_load()
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_anti_aliasing(anti_aliasing)
	set_quality(quality)

func set_master_volume(v: float) -> void:
	master_volume = v
	_apply_bus("Master", v)
	_save()

func set_music_volume(v: float) -> void:
	music_volume = v
	_apply_bus("Music", v)
	_save()

func _apply_bus(bus_name: String, volume_0_100: float) -> void:
	var id = AudioServer.get_bus_index(bus_name)
	if id == -1:
		return
	var linear = max(volume_0_100 / 100.0, 0.0001)
	AudioServer.set_bus_volume_db(id, linear_to_db(linear))

func set_anti_aliasing(index: int) -> void:
	anti_aliasing = index
	var vp:= get_tree().root.get_viewport()
	vp.msaa_3d = Viewport.MSAA_DISABLED
	vp.use_taa = false
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	match index:
		1: vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		2: vp.msaa_3d = Viewport.MSAA_4X
		3: vp.use_taa = true
	_save()
	
func set_quality(index: int) -> void:
	quality = index
	var vp := get_tree().root.get_viewport()
	match index:
		0: # Low
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			vp.positional_shadow_atlas_size = 1024
			vp.scaling_3d_scale = 0.75
			vp.mesh_lod_threshold = 4.0
		1: # High
			RenderingServer.directional_shadow_atlas_set_size(8192, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			vp.positional_shadow_atlas_size = 8192
			vp.scaling_3d_scale = 1.0
			vp.mesh_lod_threshold = 1.0
	_save()

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("graphics", "anti_aliasing", anti_aliasing)
	cfg.set_value("graphics", "quality", quality)
	cfg.save(CONFIG_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	master_volume = cfg.get_value("audio", "master_volume", master_volume)
	music_volume = cfg.get_value("audio", "music_volume", music_volume)
	anti_aliasing = cfg.get_value("graphics", "anti_aliasing", anti_aliasing)
	quality = cfg.get_value("graphics", "quality", quality)
