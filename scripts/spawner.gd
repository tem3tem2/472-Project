extends Node3D

@export var target_scene: PackedScene
@export var spawn_area_size: Vector3 = Vector3(20.0, 0.0, 20.0)  # X width, Y height range, Z depth
@export var min_height: float = 0.0
@export var max_height: float = 5.0

func _on_timer_timeout() -> void:
	var target = target_scene.instantiate()
	get_tree().current_scene.add_child(target)
	target.global_position = _get_random_spawn_position()

func _get_random_spawn_position() -> Vector3:
	var half_x := spawn_area_size.x / 2.0
	var half_z := spawn_area_size.z / 2.0

	var random_x := global_position.x + randf_range(-half_x, half_x)
	var random_y := global_position.y + randf_range(min_height, max_height)
	var random_z := global_position.z + randf_range(-half_z, half_z)

	return Vector3(random_x, random_y, random_z)
