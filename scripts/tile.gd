class_name Tile extends RefCounted


var room_id: int = -1
var astar_position_id: int = -1
var occupying_entity: Node3D = null
#All of the attacks that are on a single tile
var attack_queue: Dictionary[Creature, AttackData] = {}


func _init(init_room_id, init_astar_position_id) -> void:
	room_id = init_room_id
	astar_position_id = init_astar_position_id

func decrement_queue(creature: Creature):
	if attack_queue.has(creature) && attack_queue[creature] != null:
		attack_queue[creature].remaining_time_in_attack -= 1
		if attack_queue[creature].remaining_time_in_attack <= 0:
			if occupying_entity is Creature && creature.is_player != (occupying_entity as Creature).is_player:
				occupying_entity.health_component.take_damage(attack_queue[creature].damage)
			attack_queue.erase(creature)
			#TODO Add damage to entity in this tile depending on if its player or enemy
			return true
		return false
	printerr("Tile ", astar_position_id, " in room ", room_id, " either does not have creature ", creature, " or the attack data is null")
	return false
