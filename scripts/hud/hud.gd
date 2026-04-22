extends Control

class_name FeelHUD

@onready var ammo_label: Label = $AmmoLabel
@onready var crosshair: Control = $Crosshair
@onready var crosshair_top: Control = $Crosshair/Top
@onready var crosshair_bottom: Control = $Crosshair/Bottom
@onready var crosshair_left: Control = $Crosshair/Left
@onready var crosshair_right: Control = $Crosshair/Right
@onready var hitmarker: Label = $Hitmarker
@onready var hitmarker_timer: Timer = $HitmarkerTimer
@onready var controls_label: Label = $ControlsLabel
@onready var prompt_label: Label = $PromptLabel
@onready var stats_panel: VBoxContainer = $StatsPanel
@onready var stats_targets_label: Label = $StatsPanel/TargetsLabel
@onready var stats_streak_label: Label = $StatsPanel/StreakLabel
@onready var stats_accuracy_label: Label = $StatsPanel/AccuracyLabel
@onready var profile_label: Label = $ProfileLabel
@onready var _title_label: Label = get_node_or_null("TitleLabel") as Label
@onready var _block_tint: ColorRect = get_node_or_null("BlockTint") as ColorRect
@onready var _block_label: Label = get_node_or_null("BlockLabel") as Label
@onready var _cast_tint: ColorRect = get_node_or_null("CastTint") as ColorRect
var _cast_tint_alpha: float = 0.0
@onready var _mode_label: Label = get_node_or_null("ModeLabel") as Label

@export var crosshair_config: CrosshairConfig
@export var player_path: NodePath
@export var show_block_hint: bool = true
@export var enable_crosshair: bool = true
@export var hitmarker_color: Color = Color(1, 1, 1, 1)
@export var killmarker_color: Color = Color(1, 0.25, 0.25, 1)

var crosshair_min_size: float = 6.0
var crosshair_max_size: float = 18.0
var crosshair_spread_weight: float = 0.7
var crosshair_move_weight: float = 0.3
var crosshair_smooth_speed: float = 12.0
var crosshair_base_color: Color = Color(1, 1, 1, 1)
var _crosshair_show_hitmarker: bool = true
var _crosshair_style: String = "cross"

var _connected_weapon: WeaponBase
var _crosshair_current_size: float = 0.0
var _shots_fired: int = 0
var _shots_hit: int = 0
var _targets_hit: int = 0
var _current_streak: int = 0
var _best_streak: int = 0
var _player: Node

# only for ammo polling fallback
var _last_ammo_current: int = -1
var _last_ammo_max: int = -1
var _last_shot_was_hit: bool = false

# HUD stat colors
var COLOR_BAD: Color = Color(1.0, 0.20, 0.20, 1.0)
var COLOR_WARN: Color = Color(1.0, 0.55, 0.10, 1.0)
var COLOR_MID: Color = Color(1.0, 0.90, 0.20, 1.0)
var COLOR_GOOD: Color = Color(0.40, 1.0, 0.35, 1.0)
var COLOR_GREAT: Color = Color(0.20, 1.0, 0.80, 1.0)
var COLOR_NEUTRAL: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	if crosshair_config == null:
		# WW2 is a sensible default crosshair
		crosshair_config = preload("res://config/Crosshair_WW2.tres")

	_apply_crosshair_config()
	_crosshair_current_size = crosshair_min_size
	_set_crosshair_visible(enable_crosshair)
	_hide_hitmarker()

	if hitmarker_timer and not hitmarker_timer.timeout.is_connected(_on_HitmarkerTimer_timeout):
		hitmarker_timer.timeout.connect(_on_HitmarkerTimer_timeout)

	if controls_label != null:
		var base_controls_text := "YOUR AIM STATISTICS:"
		base_controls_text += ""
		if show_block_hint:
			base_controls_text += ""
		controls_label.text = base_controls_text

	if _title_label != null:
		_title_label.text = "ORBS! 3D aim trainer"

	if _player == null and player_path != NodePath():
		_player = get_node_or_null(player_path)

	if _player == null:
		var from_group := get_tree().get_first_node_in_group("player")
		if from_group:
			_player = from_group

	_update_block_visual(false)
	_update_stats_labels()

	# make sure ammo shows something immediately if weapon already exists later
	if ammo_label:
		ammo_label.text = "AMMO: 0 / 0"
		ammo_label.modulate = COLOR_BAD

func connect_weapon(weapon: WeaponBase) -> void:
	if _connected_weapon:
		if _connected_weapon.hit_confirmed.is_connected(_on_hit_confirmed):
			_connected_weapon.hit_confirmed.disconnect(_on_hit_confirmed)
		if _connected_weapon.has_signal("kill_confirmed") and _connected_weapon.kill_confirmed.is_connected(_on_kill_confirmed):
			_connected_weapon.kill_confirmed.disconnect(_on_kill_confirmed)
		if _connected_weapon.has_signal("shot_fired") and _connected_weapon.shot_fired.is_connected(_on_shot_fired):
			_connected_weapon.shot_fired.disconnect(_on_shot_fired)
		if _connected_weapon.ammo_changed.is_connected(_on_ammo_changed):
			_connected_weapon.ammo_changed.disconnect(_on_ammo_changed)

	_connected_weapon = weapon

	if _connected_weapon:
		if not _connected_weapon.ammo_changed.is_connected(_on_ammo_changed):
			_connected_weapon.ammo_changed.connect(_on_ammo_changed)

		if not _connected_weapon.hit_confirmed.is_connected(_on_hit_confirmed):
			_connected_weapon.hit_confirmed.connect(_on_hit_confirmed)

		if _connected_weapon.has_signal("kill_confirmed") and not _connected_weapon.kill_confirmed.is_connected(_on_kill_confirmed):
			_connected_weapon.kill_confirmed.connect(_on_kill_confirmed)

		if _connected_weapon.has_signal("shot_fired") and not _connected_weapon.shot_fired.is_connected(_on_shot_fired):
			_connected_weapon.shot_fired.connect(_on_shot_fired)

		_force_refresh_ammo()
		_hide_hitmarker()

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	_update_ammo_display(current, max_ammo)

func _update_ammo_display(current: int, max_ammo: int) -> void:
	_last_ammo_current = current
	_last_ammo_max = max_ammo

	if ammo_label:
		ammo_label.text = "AMMO: %d / %d" % [current, max_ammo]

		var ratio: float = 0.0
		if max_ammo > 0:
			ratio = float(current) / float(max_ammo)

		ammo_label.modulate = _get_ammo_color(ratio)

func _force_refresh_ammo() -> void:
	if _connected_weapon == null:
		return

	var current: int = 0
	var max_ammo: int = 0

	if _connected_weapon.has_method("get_current_ammo"):
		current = _connected_weapon.get_current_ammo()

	if _connected_weapon.get("config") != null and _connected_weapon.config != null:
		if "mag_size" in _connected_weapon.config:
			max_ammo = _connected_weapon.config.mag_size

	_update_ammo_display(current, max_ammo)

func _on_hit_confirmed(target: Node) -> void:
	if target == null:
		return

	if not _crosshair_show_hitmarker:
		_shots_hit += 1
		_update_stats_labels()
		return

	_show_hitmarker(hitmarker_color)

	if hitmarker_timer:
		hitmarker_timer.start()

	_shots_hit += 1
	_update_stats_labels()

func _on_kill_confirmed(target: Node) -> void:
	if target == null:
		return
		
	_last_shot_was_hit = true

	if not _crosshair_show_hitmarker:
		_targets_hit += 1
		_current_streak += 1
		if _current_streak > _best_streak:
			_best_streak = _current_streak
		_update_stats_labels()
		return

	_show_hitmarker(killmarker_color)

	if hitmarker_timer:
		hitmarker_timer.start()

	_targets_hit += 1
	_current_streak += 1

	if _current_streak > _best_streak:
		_best_streak = _current_streak

	_update_stats_labels()

func _show_hitmarker(color: Color) -> void:
	if hitmarker == null or hitmarker_timer == null:
		return

	hitmarker.modulate = color
	hitmarker.modulate.a = 1.0
	hitmarker.visible = true
	hitmarker_timer.start()

func _hide_hitmarker() -> void:
	if hitmarker == null:
		return
	hitmarker.visible = false

func _on_HitmarkerTimer_timeout() -> void:
	_hide_hitmarker()

func _get_movement_factor() -> float:
	var moving := (
		Input.is_action_pressed("move_forward")
		or Input.is_action_pressed("move_backward")
		or Input.is_action_pressed("move_left")
		or Input.is_action_pressed("move_right")
	)

	var sprinting := Input.is_action_pressed("sprint")

	if not moving:
		return 0.0

	return 1.5 if sprinting else 1.0

func _update_crosshair(delta: float) -> void:
	if not enable_crosshair:
		return
	if crosshair == null:
		return

	var spread_factor: float = 0.0
	if _connected_weapon and _connected_weapon.has_method("get_spread_ratio"):
		spread_factor = _connected_weapon.get_spread_ratio()

	var move_factor := _get_movement_factor()
	var combined := spread_factor * crosshair_spread_weight + move_factor * crosshair_move_weight
	combined = clamp(combined, 0.0, 1.0)

	var target_size: float = lerp(crosshair_min_size, crosshair_max_size, combined)
	var t: float = clamp(crosshair_smooth_speed * delta, 0.0, 1.0)
	_crosshair_current_size = lerp(_crosshair_current_size, target_size, t)

	if crosshair_top:
		crosshair_top.position = Vector2(-crosshair_top.size.x * 0.5, -_crosshair_current_size - crosshair_top.size.y)

	if crosshair_bottom:
		crosshair_bottom.position = Vector2(-crosshair_bottom.size.x * 0.5, _crosshair_current_size)

	if crosshair_left:
		crosshair_left.position = Vector2(-_crosshair_current_size - crosshair_left.size.x, -crosshair_left.size.y * 0.5)

	if crosshair_right:
		crosshair_right.position = Vector2(_crosshair_current_size, -crosshair_right.size.y * 0.5)

func _process(delta: float) -> void:
	_update_crosshair(delta)

	var blocking := false
	if _player and _player.has_method("is_blocking") and _player.is_blocking():
		blocking = true

	_update_block_visual(blocking)

	# fade out cast tint
	if _cast_tint != null and _cast_tint_alpha > 0.0:
		_cast_tint_alpha = max(_cast_tint_alpha - delta * 2.5, 0.0)
		_cast_tint.color.a = _cast_tint_alpha

	# force ammo refresh every frame so label never gets stuck at 0/0
	if _connected_weapon:
		_force_refresh_ammo()

func set_prompt(text: String) -> void:
	if prompt_label == null:
		return

	prompt_label.text = text
	prompt_label.visible = text.strip_edges() != ""

func clear_prompt() -> void:
	set_prompt("")

func set_profile_name(profile_name: String) -> void:
	if profile_label == null:
		return

	profile_label.text = "Profile: %s" % profile_name

func _on_shot_fired() -> void:
	_last_shot_was_hit = false
	_shots_fired += 1
	_update_stats_labels()
	
	await get_tree().process_frame #stall a frame to check if bullet hits
	
	if not _last_shot_was_hit:
		_current_streak = 0
		_update_stats_labels()

func _update_stats_labels() -> void:
	var accuracy: float = 0.0
	if _shots_fired > 0:
		accuracy = float(_targets_hit) / float(_shots_fired) * 100.0

	if stats_targets_label:
		stats_targets_label.text = "Orbs Hit: %d" % _targets_hit
		stats_targets_label.modulate = _get_targets_color(_targets_hit)

	if stats_streak_label:
		stats_streak_label.text = "Best Streak: %d" % _best_streak
		stats_streak_label.modulate = _get_streak_color(_best_streak)

	if stats_accuracy_label:
		stats_accuracy_label.text = "Shots: %d  Accuracy: %d%%" % [
			_shots_fired,
			int(accuracy + 0.5)
		]
		stats_accuracy_label.modulate = _get_accuracy_color(accuracy)

func _apply_crosshair_config() -> void:
	if crosshair_config == null:
		return

	crosshair_min_size = crosshair_config.min_size
	crosshair_max_size = crosshair_config.max_size
	crosshair_spread_weight = crosshair_config.spread_weight
	crosshair_move_weight = crosshair_config.movement_weight
	crosshair_smooth_speed = crosshair_config.smooth_speed

	crosshair_base_color = crosshair_config.base_color
	hitmarker_color = crosshair_config.hit_color
	killmarker_color = crosshair_config.kill_color
	_crosshair_show_hitmarker = crosshair_config.show_hitmarker
	_crosshair_style = crosshair_config.style

	if crosshair_top:
		crosshair_top.modulate = crosshair_base_color
	if crosshair_bottom:
		crosshair_bottom.modulate = crosshair_base_color
	if crosshair_left:
		crosshair_left.modulate = crosshair_base_color
	if crosshair_right:
		crosshair_right.modulate = crosshair_base_color

func _set_crosshair_visible(should_show: bool) -> void:
	if crosshair:
		crosshair.visible = should_show
	if crosshair_top:
		crosshair_top.visible = should_show
	if crosshair_bottom:
		crosshair_bottom.visible = should_show
	if crosshair_left:
		crosshair_left.visible = should_show
	if crosshair_right:
		crosshair_right.visible = should_show

func set_crosshair_enabled(enabled: bool) -> void:
	enable_crosshair = enabled
	_set_crosshair_visible(enabled)

func show_magic_cast_flash() -> void:
	if _cast_tint == null:
		return

	_cast_tint_alpha = 0.25
	_cast_tint.color.a = _cast_tint_alpha

func set_title(text: String) -> void:
	if _title_label:
		_title_label.text = text

func set_mode_label(text: String) -> void:
	if _mode_label:
		_mode_label.text = text

func set_stats_visible(should_show: bool) -> void:
	if stats_panel:
		stats_panel.visible = should_show

func reset_stats() -> void:
	_shots_fired = 0
	_shots_hit = 0
	_targets_hit = 0
	_current_streak = 0
	_best_streak = 0
	_update_stats_labels()

func reset_bootcamp_ui() -> void:
	reset_stats()
	clear_prompt()

func _update_block_visual(is_blocking: bool) -> void:
	if _block_tint:
		_block_tint.visible = is_blocking
	if _block_label:
		_block_label.visible = is_blocking

func _get_ammo_color(ratio: float) -> Color:
	ratio = clamp(ratio, 0.0, 1.0)

	if ratio <= 0.10:
		return COLOR_BAD
	elif ratio <= 0.25:
		return Color(1.0, 0.35, 0.15, 1.0)
	elif ratio <= 0.50:
		return COLOR_WARN
	elif ratio <= 0.75:
		return COLOR_MID
	else:
		return COLOR_NEUTRAL

func _get_accuracy_color(accuracy: float) -> Color:
	if accuracy < 20.0:
		return COLOR_BAD
	elif accuracy < 40.0:
		return COLOR_WARN
	elif accuracy < 60.0:
		return COLOR_MID
	elif accuracy < 80.0:
		return COLOR_GOOD
	else:
		return COLOR_GREAT

func _get_streak_color(streak: int) -> Color:
	if streak <= 1:
		return COLOR_NEUTRAL
	elif streak <= 3:
		return COLOR_MID
	elif streak <= 6:
		return COLOR_GOOD
	else:
		return COLOR_GREAT

func _get_targets_color(targets: int) -> Color:
	if targets <= 2:
		return COLOR_NEUTRAL
	elif targets <= 5:
		return COLOR_MID
	elif targets <= 10:
		return COLOR_GOOD
	else:
		return COLOR_GREAT
