extends Node3D

enum PROCESS_MODE {
	PROCESS,
	PHYSICS
}

@export var target: Node3D
@export var speed: float
## Where on the screen the target should be held, in normalized
## coordinates. (0, 0) is top-left, (1, 1) is bottom-right, (0.5, 0.5)
## is center.
@export var screen_position: Vector2 = Vector2(0.5, 0.5)
## Required distance (in world units) between the camera and the target.
## When `<= 0` the current camera-to-target distance is preserved instead,
## letting the scene's own camera offset dictate zoom.
@export var distance: float = 0.0
@export var processing_mode: PROCESS_MODE

@onready var camera: Camera3D = $Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if processing_mode == PROCESS_MODE.PROCESS:
		update(delta)

func _physics_process(delta: float) -> void:
	if processing_mode == PROCESS_MODE.PHYSICS:
		update(delta)

func update(delta: float) -> void:
	if target == null or camera == null:
		return
	var desired := _desired_pivot_position()
	global_position = global_position.lerp(desired, speed * delta)

# Returns the pivot position that would place `target` at `screen_position`
# on the screen, assuming the camera's orientation is unchanged.
func _desired_pivot_position() -> Vector3:
	var viewport_size := camera.get_viewport().get_visible_rect().size
	var pixel_pos := screen_position * viewport_size
	# Ray direction in world space for the desired screen pixel. This
	# only depends on the camera's orientation and projection, not its
	# position, so it is stable as we move the pivot.
	var ray_normal := camera.project_ray_normal(pixel_pos)
	var cam_pos := camera.global_position
	var cam_to_target := target.global_position - cam_pos
	# Use the required distance if one is set, otherwise preserve
	# whatever distance the camera currently has from the target.
	var effective_distance := distance if distance > 0.0 else cam_to_target.length()
	# The camera is a child of the pivot, so translating the pivot by
	# `delta` translates the camera by the same amount. We want the new
	# vector from camera to target to align with `ray_normal` at
	# `effective_distance`, so:
	#     (cam_to_target) - delta = ray_normal * effective_distance
	#     delta = cam_to_target - ray_normal * effective_distance
	var delta_offset := cam_to_target - ray_normal * effective_distance
	return global_position + delta_offset
