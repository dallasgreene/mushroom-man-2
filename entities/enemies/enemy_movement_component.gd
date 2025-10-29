extends Node3D
class_name EnemyMovementComponent

var moving: bool = false
var parent_room: Room
var enemy: Enemy

func move(parent_room_input: Room, enemy_input: Enemy) -> PackedVector3Array:
	if parent_room == null:
		parent_room = parent_room_input
	if enemy == null:
		enemy = enemy_input
	var path = parent_room.pathfinding.get_point_path(parent_room.pathfinding.get_closest_point(enemy.global_position),parent_room.pathfinding.get_closest_point(Global.player.global_position))
	create_tween().tween_method(move_function, enemy.global_position, path[1], Global.ENEMY_MOVE_SPEED)
	return path
	
func move_function(value: Vector3):
	print("enemy global position: ", enemy.global_position)
	print("value: ", value )
	enemy.global_position = value

func _on_moving_finish():
	moving = false
	rotation_degrees.y = roundf(rotation_degrees.y)
	position.x = roundf(position.x)
	position.y = roundf(position.y)
	position.z = roundf(position.z)
	print("current position: ", position)
	print("path: ",parent_room.pathfinding.get_point_path(parent_room.pathfinding.get_closest_point(get_parent().global_position), parent_room.pathfinding.get_closest_point(Global.player.global_position)))
