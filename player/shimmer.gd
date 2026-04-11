class_name Shimmer extends CharacterBody3D

@export var capture_distance: float
@export var particles: GPUParticles3D
@export var particle_strength: float = 10
@export var particle_mesh: QuadMesh
@export var min_particle_size: float = 0.1
@export var max_particle_size: float = 0.75
@export var mesh: MeshInstance3D
@export var max_energy: float = 20
@export var emission_strength: float = 10

var particle_material: ParticleProcessMaterial

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

var souls_detected: int = 0
var material: StandardMaterial3D

var _energy: float = 100
var energy: float = 100 : 
	get:
		return _energy
	set(value):
		material.emission_energy_multiplier = energy/max_energy * emission_strength
		_energy = value

func _ready() -> void:
	particle_material = particles.process_material as ParticleProcessMaterial
	particle_mesh = particles.draw_pass_1 as QuadMesh
	material = mesh.get_surface_override_material(0)
	
	energy = energy # To update progress!

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		mesh.rotation.y = rotate_toward(
			mesh.rotation.y,
			Vector2(direction.x, -direction.z).angle() + deg_to_rad(90),
			delta * 8
		)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_pressed("shimmer"):
		particles.emitting = true
		
		var soul := SoulsManager.get_closest_valid_soul(global_position)
		if soul == null:
			particle_material.direction = Vector3.UP
			energy -= 0.01
			return
		
		var soul_pos = soul.global_position
		
		var has_sucked: bool = false
		
		if soul.can_suck():
			var soul_dist: float = global_position.distance_to(soul_pos)
			if soul_dist < capture_distance:
				# Emit!
				soul.suck(0.05)
				energy -= 0.05
				has_sucked = true
			particle_mesh.size = Vector2.ONE * clampf(max_particle_size - (soul_dist / capture_distance) * (max_particle_size - min_particle_size), min_particle_size, max_particle_size)
		else:
			particle_mesh.size = Vector2.ONE * min_particle_size
		
		if !has_sucked:
			energy -= 0.01
		
		particle_material.direction = (soul_pos - global_position).normalized() * particle_strength	 
	else:
		particles.emitting = false
