class_name Soul extends StaticBody3D

@export var mesh: MeshInstance3D
@export var max_energy: float = 20

var material: StandardMaterial3D
@export var energy: float = 10

func _ready() -> void:
	SoulsManager.register_soul(self)
	material = mesh.mesh.surface_get_material(0)
	suck(0) # To init

func can_suck() -> bool:
	return energy < 50 

func suck(amount: float) -> void:
	energy += amount
	material.albedo_color.a = energy/max_energy
