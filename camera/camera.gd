extends Node3D

enum PROCESS_MODE {
	PROCESS,
	PHYSICS
}

@export var target: Node3D
@export var speed: float
@export var processing_mode: PROCESS_MODE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if processing_mode == PROCESS_MODE.PROCESS:
		update(delta)

func _physics_process(delta: float) -> void:
	if processing_mode == PROCESS_MODE.PHYSICS:
		update(delta)

func update(delta: float) -> void:
	global_position = global_position.lerp(target.global_position, speed * delta)
