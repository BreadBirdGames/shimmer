class_name Shimmer extends CharacterBody3D

signal reached_trapper

@export var capture_distance: float
@export var particles: GPUParticles3D
@export var particle_strength: float = 10
var particle_mesh: QuadMesh
@export var min_particle_size: float = 0.1
@export var max_particle_size: float = 0.75
@export var mesh: MeshInstance3D
@export var pivot: Node3D
@export var player: AnimationPlayer

@export var light_mesh: MeshInstance3D
@export var max_energy: float = 20
@export var emission_strength: float = 10

# EXTREMELY hacky...
@export var last_soul: Node3D

var particle_material: ParticleProcessMaterial

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

var souls_detected: int = 0
var material: StandardMaterial3D
var light_material: StandardMaterial3D
var interacting: bool = false

var target_energy: float = 100
var _energy: float = 100
var energy: float = 100 : 
	get:
		return _energy
	set(value):
		light_material.emission_energy_multiplier = energy/max_energy * emission_strength
		_energy = value

var trapper: Node3D = null

func _ready() -> void:
	SoulsManager.player = self
	OurCamera.take_camera(self)
	
	particle_material = particles.process_material as ParticleProcessMaterial
	particle_mesh = particles.draw_pass_1 as QuadMesh
	material = mesh.get_surface_override_material(0)
	light_material = light_mesh.get_surface_override_material(0)
	
	energy = energy # To update progress!

func trap_to(target: Node3D) -> void:
	trapper = target

func _physics_process(delta: float) -> void:
	if trapper != null:
		trap_update(delta)
	elif interacting: # replace with condition
		interaction_update(delta)
	else:
		regular_update(delta)
	
	if energy != target_energy:
		energy = lerpf(energy, target_energy, delta)
	
	if velocity.length() > 0.1:
		if player.current_animation != "Walk":
			player.play("Walk")
	else:
		if player.current_animation != "uwu":
			player.play("uwu")

func reset_pose(delta: float) -> void:
	if player.current_animation != "uwu":
		player.play("uwu")
	pivot.rotation.y = rotate_toward(
			pivot.rotation.y,
			deg_to_rad(180),
			delta * 8
		)

func trap_update(delta: float) -> void:
	global_position = global_position.lerp(trapper.global_position, delta * 0.35)
	
	reset_pose(delta)
	
	if abs(global_position - trapper.global_position).length() < 3.5: # kinda high, we know
		reached_trapper.emit()
		interacting = true
		trapper = null

func interaction_update(delta: float) -> void:
	reset_pose(delta)
	
	var soul: Soul = SoulsManager.get_closest_soul(global_position)
	particle_mesh.size = Vector2.ONE * max_particle_size
	if soul != null:
		particle_material.direction = (soul.global_position - global_position).normalized() * particle_strength
	else:
		particle_material.direction = (last_soul.global_position - global_position).normalized() * particle_strength

func regular_update(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		pivot.rotation.y = rotate_toward(
			pivot.rotation.y,
			Vector2(direction.x, -direction.z).angle() + deg_to_rad(90),
			delta * 8
		)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	var soul := SoulsManager.get_closest_valid_soul(global_position)
	var soul_pos: Vector3
	
	if soul == null:
		soul_pos = Vector3.ZERO
	else:
		soul_pos = soul.global_position
		if soul.can_suck() && Input.is_action_pressed("shimmer"):
			var soul_dist: float = global_position.distance_to(soul_pos)
			if soul_dist < capture_distance:
				# Emit!
				target_energy -= soul.suck()
				interacting = true
		else:
			particle_mesh.size = Vector2.ONE * min_particle_size
	particle_material.direction = (soul_pos - global_position).normalized() * particle_strength	 
