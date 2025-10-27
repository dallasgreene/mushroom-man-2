extends Node


var areas: Array[MoveableArea] = []


func register_moveable_area(moveable_area: MoveableArea) -> int:
	areas.push_back(moveable_area)
	return areas.size() - 1


func deregister_moveable_area(moveable_area_index: int) -> void:
	areas.remove_at(moveable_area_index)


func are_floats_close_enough(float1: float, float2: float, tolerance: float) -> bool:
	return abs(float1 - float2) < tolerance


func can_move_to(global_coordinate: Vector3) -> bool:
	for area in areas:
		# Keep in mind that global_position of the MoveableArea is the CENTER
		if is_equal_approx(area.global_position.y, global_coordinate.y):
			if are_floats_close_enough(area.global_position.x, global_coordinate.x, area.size.x / 2):
				if are_floats_close_enough(area.global_position.z, global_coordinate.z, area.size.z / 2):
					return true
	return false
