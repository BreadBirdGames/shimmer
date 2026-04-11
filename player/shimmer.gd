class_name Shimmer extends CharacterBody3D

@export var label: Label
@export var energyBar: ProgressBar
@export var capture_distance: float
@export var particles: GPUParticles3D
@export var particle_strength: float = 10

var particle_material: ParticleProcessMaterial

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

var souls_detected: int = 0

var _energy: float = 100
var energy: float = 100 : 
	get:
		return _energy
	set(value):
		energyBar.value = value
		_energy = value

func _ready() -> void:
	energy = energy # To update progress!
	particle_material = particles.process_material as ParticleProcessMaterial

func switch_top_label(show: bool) -> void:
	label.visible = show

func _physics_process(delta: float) -> void:
	#DebugDraw3D.draw_arrow(global_position, global_position + Vector3(capture_distance, 0, 0))
	
	if Input.is_action_pressed("shimmer"):
		particles.emitting = true
		
		var soul := SoulsManager.get_closest_soul(global_position)
		var soul_pos = soul.global_position
		label.text = "(" + str(soul_pos.x) + ", " + str(soul_pos.y) + ", " +  str(soul_pos.z) + ")"
		
		var has_sucked: bool = false
		if global_position.distance_to(soul_pos) < capture_distance:
			# Emit!
			if soul.can_suck():
				soul.suck(0.1)
				energy -= 0.1
				has_sucked = true
		
		if !has_sucked:
			energy -= 0.05
		
		particle_material.direction = (soul_pos - global_position).normalized() * particle_strength	 
	else:
		particles.emitting = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Soul:
		souls_detected += 1
		#switch_top_label(souls_detected > 0)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Soul:
		souls_detected -= 1
		#switch_top_label(souls_detected > 0)
