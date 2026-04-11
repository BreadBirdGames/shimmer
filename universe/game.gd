extends Node3D

@export var center_hitbox: Area3D
@export var blackhole_box: Node3D

func _ready() -> void:
	SoulsManager.souls_changed.connect(self.souls_changed)

func souls_changed(souls_amount: int) -> void:
	souls_amount -= 1
	if souls_amount <= 0:
		center_hitbox.monitoring = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Shimmer:
		var shimmer: Shimmer = body as Shimmer
		shimmer.trap_to(blackhole_box)
