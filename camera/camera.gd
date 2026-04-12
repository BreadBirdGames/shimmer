extends Node3D

enum PROCESS_MODE {
	PROCESS,
	PHYSICS
}

@export var speed: float
@export var screen_position: Vector2 = Vector2(0.5, 0.5)
@export var distance: float = 0.0
@export var processing_mode: PROCESS_MODE
@export var angle_x: float = -45

@onready var camera: Camera3D = $Camera3D

var targets: Array[Node3D]

func take_camera(node: Node3D) -> void:
	targets.append(node)

func give_camera(node: Node3D) -> void:
	targets.erase(node)

func _process(delta: float) -> void:
	if processing_mode == PROCESS_MODE.PROCESS:
		update(delta)

func _physics_process(delta: float) -> void:
	if processing_mode == PROCESS_MODE.PHYSICS:
		update(delta)

func update(delta: float) -> void:
	if targets.size() < 1 or camera == null:
		return
	var desired := _desired_pivot_position()
	global_position = global_position.lerp(desired, speed * delta)
	camera.rotation.x = lerpf(camera.rotation.x, deg_to_rad(angle_x), delta * speed)

func _midpoint() -> Vector3:
	var center := Vector3.ZERO
	for target in targets:
		center += target.global_position
	return center / targets.size()

func _desired_pivot_position() -> Vector3:
	var viewport_size := camera.get_viewport().get_visible_rect().size
	var pixel_pos := screen_position * viewport_size
	var ray_normal := camera.project_ray_normal(pixel_pos)
	var cam_pos := camera.global_position
	var cam_to_target := _midpoint() - cam_pos
	var effective_distance := distance if distance > 0.0 else cam_to_target.length()
	var delta_offset := cam_to_target - ray_normal * effective_distance
	return global_position + delta_offset
