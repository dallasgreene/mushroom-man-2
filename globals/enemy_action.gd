extends Node


var enemy_movement_signal_count: int = 0
var enemy_attack_signal_count: int = 0

var enemy_movement_signal_count_limit: int = 0
var enemy_attack_signal_count_limit: int = 0

func _ready():
	SignalBus.enemies_take_turn.connect(_enemies_take_turn)
	SignalBus.enemy_movement_received.connect(_enemy_movement_counter)
	SignalBus.enemy_attack_received.connect(_enemy_attack_counter)

## Triggers all enemies to start taking their turn. Movement happens first,
## then attacks
func _enemies_take_turn() -> void:
	enemy_movement_signal_count_limit = SignalBus.enemy_movement_start.get_connections().size()
	enemy_attack_signal_count_limit = SignalBus.enemy_attack_start.get_connections().size()
	if enemy_movement_signal_count_limit>0:
		SignalBus.enemy_movement_start.emit()
	elif enemy_attack_signal_count_limit>0:
		SignalBus.enemy_attack_start.emit()
	else:
		SignalBus.enemies_finished_acting.emit()

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
		SignalBus.enemies_finished_acting.emit()
