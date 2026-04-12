extends Node3D

@export var center_hitbox: Area3D
@export var blackhole_box: Node3D
@export var animator: AnimationPlayer

@export var wasd_keys: Control
@export var e_key: Control

func _ready() -> void:
	SoulsManager.souls_changed.connect(self.souls_changed)

func souls_changed(souls_amount: int) -> void:
	souls_amount -= 1
	if souls_amount <= 0:
		center_hitbox.monitoring = true

func _process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		var tween := get_tree().create_tween()
		tween.tween_property(wasd_keys, "modulate", Color.TRANSPARENT, 0.5)
	
	var e_pressed := Input.is_action_just_pressed("shimmer")
	
	if e_pressed:
		var tween := get_tree().create_tween()
		tween.tween_property(e_key, "modulate", Color.TRANSPARENT, 0.5)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Shimmer:
		var shimmer: Shimmer = body as Shimmer
		shimmer.trap_to(blackhole_box)

func _on_shimmer_reached_trapper() -> void:
	animator.play("Ending")
