extends MeshInstance3D

@onready var cam = get_viewport().get_camera_3d()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cam == null:
		return
	
	var dir = cam.global_transform.origin - global_transform.origin
	dir.y = 0
	dir = dir.normalized()
	
	var target_rot = atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_rot + PI, 5 * delta)
