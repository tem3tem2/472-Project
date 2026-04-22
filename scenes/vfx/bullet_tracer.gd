extends Node3D

@export var lifetime: float = 0.1
@export var emission_color: Color = Color(1.0, 0.95, 0.75)
@export var emission_energy: float = 6.0

@onready var _beam: MeshInstance3D = $BeamMesh
var _material: StandardMaterial3D
var _elapsed: float = 0.0

func _ready() -> void:
	if _beam == null:
		return
	# Build a fresh material so emission/transparency are guaranteed to be set
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = Color(emission_color.r, emission_color.g, emission_color.b, 1.0)
	_material.emission_enabled = true
	_material.emission = emission_color
	_material.emission_energy_multiplier = emission_energy
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_beam.material_override = _material
	
func configure(from: Vector3, to: Vector3) -> void:
	global_position = from
	if from.distance_to(to) < 0.001:
		queue_free()
		return
	look_at(to, Vector3.UP)
	var length: float = from.distance_to(to)
	_beam.position = Vector3(0, 0, -length / 2.0)
	_beam.scale = Vector3(1, 1, length)

func _process(delta: float) -> void:
	_elapsed += delta
	var t: float = clamp(_elapsed / lifetime, 0.0, 1.0)
	if _material:
		_material.albedo_color.a = 1.0 - t
		_material.emission_energy_multiplier = lerp(emission_energy, 0.0, t)
	if _elapsed >= lifetime:
		queue_free()
