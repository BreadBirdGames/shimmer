extends Node

var souls: Array[Soul]

func _ready() -> void:
	pass

func register_soul(soul: Soul) -> void:
	souls.append(soul)

func get_closest_soul(target_pos: Vector3) -> Soul:
	var current_soul: Soul
	
	for soul: Soul in souls:
		var soul_dist: float = target_pos.distance_to(soul.global_position)
		var current_dist: float
		
		if current_soul:
			current_dist = target_pos.distance_to(current_soul.global_position)
		else:
			current_dist = 999999999999999
		
		if soul_dist < current_dist:
			current_soul = soul
	
	return current_soul
