class_name Soul extends StaticBody3D

@export var mesh: MeshInstance3D
@export var emission_strength: float = 10
@export var max_energy: float = 20

var material: StandardMaterial3D
@export var energy: float = 5

func _ready() -> void:
	SoulsManager.register_soul(self)
	material = mesh.mesh.surface_get_material(0)
	suck(0) # To init

func can_suck() -> bool:
	return energy < max_energy

func suck(amount: float) -> void:
	energy += amount
	material.emission_energy_multiplier = energy/max_energy * emission_strength
	
	if energy >= max_energy:
		SoulsManager.register_finished(self)
