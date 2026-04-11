extends Node

var souls: Array[Soul]

func print_souls():
	for soul: Soul in souls:
		print(soul)
		print(soul.global_position)

func _ready() -> void:
	call_deferred("print_souls")

func register_soul(soul: Soul) -> void:
	souls.append(soul)

func get_closest_soul(target_pos: Vector3) -> Soul:
	var shortest_soul: Soul
	var shortest_distance: float = INF
	
	for soul: Soul in souls:
		var distance = target_pos.distance_to(soul.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			shortest_soul = soul
	
	return shortest_soul
