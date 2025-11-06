extends Node


## References to the actual room objects
var rooms: Dictionary[int, Room] = {}
var current_room: int = 0
var pending_attacks: Dictionary[int, Array] = {}



func register_room(room_id: int, room: Room) -> void:
	rooms[room_id] = room


func queue_attack(
	attack_id: int,
	attack_data: TileAttackData,
	tiles_affected: Array[Vector3i],
) -> void:
	pending_attacks[attack_id] = tiles_affected
	for tile_affected_pos in tiles_affected:
		var tile_affected = rooms[current_room].get_tile(tile_affected_pos.x, tile_affected_pos.z)
		tile_affected.queue_attack(attack_id, attack_data)


func dequeue_attack(attack_id: int) -> void:
	for tile_affected_pos in pending_attacks[attack_id]:
		var tile_affected = rooms[current_room].get_tile(tile_affected_pos.x, tile_affected_pos.z)
		tile_affected.dequeue_attack(attack_id)
	pending_attacks.erase(attack_id)
