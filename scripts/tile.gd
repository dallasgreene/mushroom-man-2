class_name Tile extends RefCounted


var room_id: int = -1
var astar_position_id: int = -1
var occupying_entity: Node3D = null
var attack_queue: Dictionary[int, TileAttackData] = {}


func _init(init_room_id: int, init_astar_position_id: int) -> void:
	room_id = init_room_id
	astar_position_id = init_astar_position_id


func queue_attack(attack_id: int, attack_data: TileAttackData) -> void:
	attack_queue[attack_id] = attack_data
	print("attack queued")


func dequeue_attack(attack_id: int) -> void:
	attack_queue.erase(attack_id)
