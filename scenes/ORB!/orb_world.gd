extends Node3D

@onready var _settings_menu: Panel = $SettingsBG
@onready var player: FeelPlayer = $FeelPlayer
@onready var hud: FeelHUD = $HUD

#Spawning stuff
@export var target_scene: PackedScene
@export var spawn_area_size: Vector3 = Vector3(20.0, 0.0, 20.0)  # X width, Y height range, Z depth
@export var min_height: float = 0.0
@export var max_height: float = 5.0
@export var target_radius: float = 0.5  # match your target's collision radius
@export var max_attempts: int = 10  # give up after this many tries

func _ready() -> void:
	# Wait a frame to ensure weapon is fully initialized
	await get_tree().process_frame
	
	var weapon = player.weapon_rig.active_weapon
	
	if weapon != null:
		hud.connect_weapon(weapon)
	else:
		push_error("ObrWorld: Could not find active weapon from player.weapon_rig")
		
	if _settings_menu:
		_settings_menu.hide()
		_settings_menu.closed.connect(_on_settings_closed)
		_settings_menu.home_requested.connect(_on_home_requested)
		_settings_menu.show_home_button(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _settings_menu.visible:
			_settings_menu.hide()
			_on_settings_closed()
		else:
			_open_settings()
		get_viewport().set_input_as_handled()

func _open_settings() -> void:
	_settings_menu.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_settings_closed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_home_requested() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_timer_timeout() -> void:
	var spawn_pos := _get_valid_spawn_position()
	if spawn_pos == null:
		return  # no valid position found, skip this spawn

	var target = target_scene.instantiate()
	get_tree().current_scene.add_child(target)
	target.global_position = spawn_pos
	
func _get_valid_spawn_position() -> Vector3:
	var space_state := get_world_3d().direct_space_state

	for i in max_attempts:
		var candidate := _get_random_spawn_position()

		var shape := SphereShape3D.new()
		shape.radius = target_radius

		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = shape
		query.transform = Transform3D(Basis.IDENTITY, candidate)
		query.collision_mask = 0xFFFFFFFF  # check all layers, or narrow this down

		var results := space_state.intersect_shape(query)
		if results.is_empty():
			return candidate  # no overlap, good to go

	print("Spawner: could not find a free position after %d attempts" % max_attempts)
	return Vector3(-500, -500, -500)

func _get_random_spawn_position() -> Vector3:
	var half_x := spawn_area_size.x / 2.0
	var half_z := spawn_area_size.z / 2.0

	var random_x := global_position.x + randf_range(-half_x, half_x)
	var random_y := global_position.y + randf_range(min_height, max_height)
	var random_z := global_position.z + randf_range(-half_z, half_z)

	return Vector3(random_x, random_y, random_z)
