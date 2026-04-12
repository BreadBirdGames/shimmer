class_name Soul extends StaticBody3D

@export var mesh: MeshInstance3D
@export var emission_strength: float = 10
@export var max_energy: float = 20

var material: StandardMaterial3D
@export var energy: float = 5

@export var story_textures: Array[Texture2D]
@export var story_container: TextureRect
@export var story_label: Label
@export var story: CanvasLayer

var story_index: int = 0

func _ready() -> void:
	SoulsManager.register_soul(self)
	material = mesh.mesh.surface_get_material(0)
	material.emission_energy_multiplier = energy/max_energy * emission_strength
	
	story.hide()
	story_crement(0)

func can_suck() -> bool:
	return energy < max_energy

func suck() -> float:
	energy = max_energy
	story.show()
	
	return max_energy - energy

#func suck(amount: float) -> void:
#	energy += amount
#	material.emission_energy_multiplier = energy/max_energy * emission_strength
#	
#	if energy >= max_energy:
#		SoulsManager.register_finished(self)

func story_crement(dir: int ) -> void:
	story_index += dir
	story_index = wrapi(story_index, 0, story_textures.size())
	
	story_label.text = str(story_index + 1) + "/" + str(story_textures.size())
	story_container.texture = story_textures[story_index]

func _on_button_left_pressed() -> void:
	story_crement(-1)

func _on_button_right_pressed() -> void:
	story_crement(1)
