extends Node


const ROTATE_SPEED = 0.2
const MOVE_SPEED = 0.2
const ENEMY_MOVE_SPEED = 0.1
## The size of a tile in meters
const TILE_SIZE: int = 2

var player: Player
var next_room_id: int = 0
var enemy_movement_signal_count: int = 0
var enemy_attack_signal_count: int = 0

var enemy_movement_signal_count_limit: int = 0
var enemy_attack_signal_count_limit: int = 0

func _ready():
	SignalBus.enemy_movement_received.connect(_enemy_movement_counter)
	SignalBus.enemy_attack_received.connect(_enemy_attack_counter)

func register_player(player_input:Player):
	self.player = player_input


## Every room should call this on _ready to get its ID
func get_next_available_room_id() -> int:
	next_room_id += 1
	return next_room_id - 1

func timeline_process() -> void:
	enemy_movement_signal_count_limit = SignalBus.enemy_movement_start.get_connections().size()
	enemy_attack_signal_count_limit = SignalBus.enemy_attack_start.get_connections().size()
	if SignalBus.enemy_movement_received.get_connections().size()>0:
		SignalBus.enemy_movement_start.emit()
	elif SignalBus.enemy_attack_received.get_connections().size()>0:
		SignalBus.enemy_movement_start.emit()

func _enemy_movement_counter():
	enemy_movement_signal_count += 1
	if enemy_movement_signal_count >= enemy_movement_signal_count_limit:
		enemy_movement_signal_count_limit = 0
		enemy_movement_signal_count = 0
		SignalBus.enemy_attack_start.emit()

func _enemy_attack_counter():
	enemy_attack_signal_count += 1
	if enemy_attack_signal_count >= enemy_attack_signal_count_limit:
		enemy_attack_signal_count_limit = 0
		enemy_attack_signal_count = 0
		SignalBus.turn_ended.emit()
