extends Node

const CONFIG_PATH := "user://settings.cfg"
const DEFAULT_ENV_PATH := "res://default_env.tres"

var env: Environment
var master_volume: float = 100.0
var music_volume: float = 100.0
var render_scale: float = 1.0
var upscaler: int = 0
var anti_aliasing: int = 0
var ssao_enabled: bool = false
var bloom_enabled: bool = false
var volumetric_fog_enabled: bool = false
var sdfgi_enabled: bool = false # Signed Distance Field Global Illumination

func _ready() -> void:
	env = load(DEFAULT_ENV_PATH) as Environment
	_load()
	print("Environment loaded: ", env != null)
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_anti_aliasing(anti_aliasing)
	set_render_scale(render_scale)
	set_upscaler(upscaler)
	set_ssao_enabled(ssao_enabled)
	set_bloom_enabled(bloom_enabled)
	set_volumetric_fog_enabled(volumetric_fog_enabled)
	set_sdfgi_enabled(sdfgi_enabled)

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

func set_render_scale(value: float) -> void:
	render_scale = value
	var vp := get_tree().root.get_viewport()
	vp.scaling_3d_scale = value
	_save()

func set_upscaler(index: int) -> void:
	upscaler = index
	var vp := get_tree().root.get_viewport()
	match index:
		0: vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		1: vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		2: 
			vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
			vp.use_taa = false
	_save()

func set_bloom_enabled(value: bool) -> void:
	bloom_enabled = value
	if env:
		env.glow_enabled = value
	_save()
	
func set_ssao_enabled(value: bool) -> void:
	ssao_enabled = value
	if env:
		env.ssao_enabled = value
	_save()

func set_volumetric_fog_enabled(value: bool) -> void:
	volumetric_fog_enabled = value
	if env:
		env.volumetric_fog_enabled = value
	_save()
	
func set_sdfgi_enabled(value: bool) -> void:
	sdfgi_enabled = value
	if env:
		env.sdfgi_enabled = value
	_save()

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("graphics", "anti_aliasing", anti_aliasing)
	cfg.set_value("graphics", "render_scale", render_scale)
	cfg.set_value("graphics", "upscaler", upscaler)
	cfg.set_value("graphics", "ssao_enabled", ssao_enabled)
	cfg.set_value("graphics", "bloom_enabled", bloom_enabled)
	cfg.set_value("graphics", "volumetric_fog_enabled", volumetric_fog_enabled)
	cfg.set_value("graphics", "sdfgi_enabled", sdfgi_enabled)
	cfg.save(CONFIG_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	master_volume = cfg.get_value("audio", "master_volume", master_volume)
	music_volume = cfg.get_value("audio", "music_volume", music_volume)
	anti_aliasing = cfg.get_value("graphics", "anti_aliasing", anti_aliasing)
	render_scale = cfg.get_value("graphics", "render_scale", render_scale)
	upscaler = cfg.get_value("graphics", "upscaler", upscaler)
	ssao_enabled = cfg.get_value("graphics", "ssao_enabled", ssao_enabled)
	bloom_enabled = cfg.get_value("graphics", "bloom_enabled", bloom_enabled)
	volumetric_fog_enabled = cfg.get_value("graphics", "volumetric_fog_enabled", volumetric_fog_enabled)
	sdfgi_enabled = cfg.get_value("graphics", "sdfgi_enabled", sdfgi_enabled)
