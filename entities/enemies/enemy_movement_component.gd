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
	var path = parent_room.pathfinding.get_point_path(
		parent_room.pathfinding.get_closest_point(enemy.global_position, true),
		parent_room.pathfinding.get_closest_point(Global.player.global_position)
	)
	if path.size() <= 1:
		return path
	var next_position = path[1]
	var next_position_int = Vector3i(roundi(next_position.x), roundi(next_position.y), roundi(next_position.z))
	enemy.tile_position = next_position_int
	parent_room.move_entity(
		Vector3i(roundi(enemy.global_position.x), roundi(enemy.global_position.y), roundi(enemy.global_position.z)),
		next_position_int,
		enemy
	)
	enemy.look_at(Vector3(Global.player.global_position.x, enemy.global_position.y, Global.player.global_position.z))
	enemy.rotation_degrees.y = round(enemy.rotation_degrees.y/90)*90
	var temp_vector = Vector3(enemy_input.sprite.global_position)
	enemy_input.global_position = Vector3i(roundi(next_position.x), roundi(next_position.y), roundi(next_position.z))
	enemy_input.sprite.global_position = Vector3(temp_vector)
	
	temp_vector = Vector3(enemy_input.global_position)
	temp_vector.y = enemy_input.sprite.global_position.y
	create_tween().tween_method(move_function, enemy.sprite.global_position, temp_vector, Global.ENEMY_MOVE_SPEED).finished.connect(_on_moving_finish)
	return path

func move_function(value: Vector3):
	enemy.sprite.global_position = value

func _on_moving_finish():
	moving = false
	enemy.global_position.x = roundf(enemy.global_position.x)
	enemy.global_position.y = roundf(enemy.global_position.y)
	enemy.global_position.z = roundf(enemy.global_position.z)
	#print("current position: ", global_position)
	#print("path: ",parent_room.pathfinding.get_point_path(parent_room.pathfinding.get_closest_point(get_parent().global_position), parent_room.pathfinding.get_closest_point(Global.player.global_position)))
