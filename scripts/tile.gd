class_name Tile extends RefCounted


var room_id: int = -1
var astar_position_id: int = -1
var occupying_entity: Node3D = null
var attack_queue: Array[TileAttackData] = []


func _init(init_room_id, init_astar_position_id) -> void:
	room_id = init_room_id
	astar_position_id = init_astar_position_id
