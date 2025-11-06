extends Node
class_name TileAttackData

var time_to_start: int
var damage: int
var is_from_player: bool
var linger_time: int


func _init(init_time_to_start: int, init_damage: int, init_is_from_player: bool, init_linger_time: int = 0) -> void:
	time_to_start = init_time_to_start
	damage = init_damage
	is_from_player = init_is_from_player
	linger_time = init_linger_time
