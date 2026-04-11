extends Node

signal souls_changed(souls_amount: int)

var souls: Array[Soul]

func register_soul(soul: Soul) -> void:
	souls.append(soul)

func register_finished(soul: Soul) -> void:
	souls.erase(soul)
	souls_changed.emit(souls.size())

func get_closest_soul(target_pos: Vector3) -> Soul:
	var shortest_soul: Soul
	var shortest_distance: float = INF
	
	for soul: Soul in souls:
		var distance = target_pos.distance_to(soul.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			shortest_soul = soul
	
	return shortest_soul

func get_closest_valid_soul(target_pos: Vector3) -> Soul:
	var shortest_soul: Soul = null
	var shortest_distance: float = INF
	
	if souls.size() == 0:
		return null
	
	for soul: Soul in souls:
		if !soul.can_suck():
			continue
		
		var distance = target_pos.distance_to(soul.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			shortest_soul = soul
	
	return shortest_soul
