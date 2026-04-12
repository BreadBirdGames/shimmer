class_name Soul extends StaticBody3D

@export var mesh: MeshInstance3D
@export var emission_strength: float = 10
@export var max_energy: float = 20

var material: StandardMaterial3D
@export var energy: float = 5

@export var story_textures: Array[Texture2D]
@export var story_container: TextureRect
@export var story_label: Label
@export var left_button: Button
@export var right_button: Button
@export var story: CanvasLayer
@export var player: AnimationPlayer

@export var particles: GPUParticles3D
var particle_material: ParticleProcessMaterial

var story_index: int = 0

func _ready() -> void:
	SoulsManager.register_soul(self)
	material = mesh.mesh.surface_get_material(0)
	material.emission_energy_multiplier = energy/max_energy * emission_strength
	
	particle_material = particles.process_material as ParticleProcessMaterial
	particles.emitting = false
	
	player.play("uwu")
	story.hide()
	story_crement(0)

func can_suck() -> bool:
	return energy < max_energy

func suck() -> float:
	energy = max_energy
	story.show()
	OurCamera.screen_position = Vector2(0.125, 0.75)
	OurCamera.angle_x = 0
	OurCamera.distance = 6
	OurCamera.take_camera(self)
	
	return max_energy - energy

func target_last_soul(last_soul: Node3D) -> void:
	particle_material.direction = (last_soul.global_position - global_position).normalized() * 10
	particles.emitting = true

func story_crement(dir: int ) -> void:
	story_index += dir
	
	if story_index < 0:
		story_index = 0
	
	if story_index == 0:
		left_button.disabled = true
	else:
		left_button.disabled = false
	
	if story_index == story_textures.size(): # OVERFLOW!
		var emission_tween: Tween = get_tree().create_tween()
		emission_tween.tween_property(material, "emission_energy_multiplier", energy/max_energy * emission_strength, 5)
		story.hide()
		SoulsManager.register_finished(self)
		OurCamera.give_camera(self)
		OurCamera.screen_position = Vector2.ONE/2
		OurCamera.angle_x = -45
		OurCamera.distance = 4
		SoulsManager.player.interacting = false
		return # And we stop
	
	story_label.text = str(story_index + 1) + "/" + str(story_textures.size())
	story_container.texture = story_textures[story_index]

func _on_button_left_pressed() -> void:
	story_crement(-1)

func _on_button_right_pressed() -> void:
	story_crement(1)
