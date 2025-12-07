extends Creature
class_name Enemy
var moving_next_turn: bool = false
var state: State = State.IDLE
var path
var local_attack_time
var attack_started = false
@export var movement_component: EnemyMovementComponent
@onready var sprite = %Sprite3D
@export var attack_data: AttackData

@onready var slime_move = $Slime_Move
@onready var slime_AttackStart = $"Slime_Attack Start"
@onready var slime_AttackLoop = $"Slime_Attack Loop"
@onready var slime_AttackFire = $"Slime_Attack Fire"

enum State{
	IDLE,
	MOVING,
	ATTACKING
}

func _ready() -> void:
	is_player = false
	if attack_component != null:
		assert(attack_data!=null, "Please set attack data")
		attack_component.attack_data = attack_data
		SignalBus.enemy_attack_start.connect(_enemy_attack_start)
	if movement_component != null:
		SignalBus.enemy_movement_start.connect(_enemy_movement_start)
		state = State.MOVING
	var current_parent = get_parent()
	while !current_parent is Room:
		current_parent = current_parent.get_parent()
	parent_room = current_parent
	local_attack_time = attack_component.attack_data.time_to_attack + 1

func _exit_tree() -> void:
	if attack_component != null && SignalBus.enemy_attack_start.is_connected(_enemy_attack_start):
		SignalBus.enemy_attack_start.disconnect(_enemy_attack_start)
	if movement_component != null && SignalBus.enemy_movement_start.is_connected(_enemy_movement_start):
		SignalBus.enemy_movement_start.disconnect(_enemy_movement_start)

func _enemy_movement_start():
	if state == State.MOVING:
		if movement_component != null:
			if moving_next_turn:
				path = movement_component.move(parent_room, self)
				slime_move.play()
				#print("path size: ", path.size())
			moving_next_turn = !moving_next_turn
			if attack_component!= null:
				if path != null && ((path.size()-1 <= attack_component.attack_data.distance) || (path.size()+1 == 1 && attack_component.attack_data.attack_type == AttackData.AttackType.CLEAVE)):
					state = State.ATTACKING
					path = null
					attack_component.create_attack(parent_room,self,attack_component.attack_data)
	SignalBus.enemy_movement_received.emit()

func _enemy_attack_start():
	if state == State.ATTACKING:
		if not attack_started:
			slime_AttackStart.play()
			slime_AttackLoop.play()
			attack_started = true
		#print(attack_component == null)
		if attack_component != null && local_attack_time > 0:
			moving_next_turn = false
			#print("in here")
			local_attack_time -= 1
			parent_room.attack_count_down(self)
			if local_attack_time == 0:
				local_attack_time = attack_component.attack_data.time_to_attack + 1
				slime_AttackFire.play()
				slime_AttackLoop.stop()
				state = State.MOVING
				attack_started = false
		elif attack_component == null:
			state = State.MOVING	
	SignalBus.enemy_attack_received.emit()


func _on_health_component_died() -> void:
	if attack_component != null:
		SignalBus.enemy_attack_start.disconnect(_enemy_attack_start)
	if movement_component != null:
		SignalBus.enemy_movement_start.disconnect(_enemy_movement_start)
	parent_room.creature_died(self)
	queue_free()
