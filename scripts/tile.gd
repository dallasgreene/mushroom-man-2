class_name Tile extends RefCounted


var room_id: int = -1
var astar_position_id: int = -1
var occupying_entity: Node3D = null
var attack_queue: Dictionary[Creature, AttackData] = {}


func _init(init_room_id, init_astar_position_id) -> void:
	room_id = init_room_id
	astar_position_id = init_astar_position_id

func decrement_queue(creature: Creature):
	attack_queue[creature].remaining_time_in_attack -= 1
	if attack_queue[creature].remaining_time_in_attack <= 0:
		attack_queue.erase(creature)
		#TODO Add damage to entity in this tile depending on if its player or enemy
