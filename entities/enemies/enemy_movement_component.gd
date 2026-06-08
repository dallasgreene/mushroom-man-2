extends Node3D
class_name EnemyMovementComponent

var moving: bool = false
var parent_room: Room
var enemy: Enemy

func get_navigation_path(parent_room_input: Room, enemy_input: Enemy) -> PackedVector3Array:
	parent_room = parent_room_input

	enemy = enemy_input
	var current_enemy_astar_id = parent_room.pathfinding.get_closest_point(enemy.global_position, true)
	parent_room.pathfinding.set_point_disabled(current_enemy_astar_id,false)
	var path = parent_room.pathfinding.get_point_path(
		current_enemy_astar_id,
		parent_room.pathfinding.get_closest_point(Global.player.global_position)
	)
	parent_room.pathfinding.set_point_disabled(current_enemy_astar_id,true)
	return path
		
func move(parent_room_input: Room, enemy_input: Enemy) -> PackedVector3Array:
	var path = get_navigation_path(parent_room_input, enemy_input)
	if path.size() <= 1:
		return path
	var next_position = path[1]
	parent_room.move_creature(
		Vector3i(roundi(enemy.global_position.x), roundi(enemy.global_position.y), roundi(enemy.global_position.z)),
		Vector3i(roundi(next_position.x), roundi(next_position.y), roundi(next_position.z)),
		enemy
	)
	#TODO fix the look at, it needs to happen after the enemy moves position
	
	var original_sprite_position = Vector3(enemy.sprite.global_position)
	enemy.global_position = Vector3i(roundi(next_position.x), roundi(next_position.y), roundi(next_position.z))
	enemy_look_at()
	next_position.y = original_sprite_position.y
	enemy.sprite.global_position = Vector3(original_sprite_position)
	create_tween().tween_method(move_function, enemy.sprite.global_position, next_position, Global.ENEMY_MOVE_SPEED).finished.connect(_on_moving_finish)
	return path

func enemy_look_at():
	enemy.look_at(Vector3(Global.player.global_position.x, enemy.global_position.y, Global.player.global_position.z))
	enemy.rotation_degrees.y = round(enemy.rotation_degrees.y/90)*90

func move_function(value: Vector3):
	enemy.sprite.global_position = value

func _on_moving_finish():
	moving = false
	enemy.global_position.x = roundf(enemy.global_position.x)
	enemy.global_position.y = roundf(enemy.global_position.y)
	enemy.global_position.z = roundf(enemy.global_position.z)
