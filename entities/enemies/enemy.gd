extends CharacterBody3D
class_name Enemy
var parent_room: Room
var moving_next_turn: bool = false
var state: State = State.IDLE
var path
var local_attack_time
@export var attack_component: AttackComponent
@export var movement_component: EnemyMovementComponent
@onready var sprite = %Sprite3D

enum State{
	IDLE,
	MOVING,
	ATTACKING
}

func _ready() -> void:
	if attack_component != null:
		SignalBus.enemy_attack_start.connect(_enemy_attack_start)
	if movement_component != null:
		SignalBus.enemy_movement_start.connect(_enemy_movement_start)
		state = State.MOVING
	var current_parent = get_parent()
	while !current_parent is Room:
		current_parent = current_parent.get_parent()
	parent_room = current_parent
	local_attack_time = attack_component.time_to_attack

func _exit_tree() -> void:
	if attack_component != null:
		SignalBus.enemy_attack_start.disconnect(_enemy_attack_start)
	if movement_component != null:
		SignalBus.enemy_movement_start.disconnect(_enemy_movement_start)

func _enemy_movement_start():
	if state == State.MOVING:
		if movement_component != null:
			if moving_next_turn:
				path = movement_component.move(parent_room, self)
				#print("path size: ", path.size())
				#print("attack_component.distance: ", attack_component.distance )
			moving_next_turn = !moving_next_turn
			if attack_component!= null:
				if path != null && ((path.size()-1 <= attack_component.distance) || (path.size()+1 == 1 && attack_component.attack_type == AttackComponent.AttackType.CLEAVE)):
					state = State.ATTACKING
					path = null
					attack_component.create_attack()
					#print(AttackComponent.AttackType.keys()[attack_component.attack_type])
	SignalBus.enemy_movement_received.emit()

func _enemy_attack_start():
	if state == State.ATTACKING:
		#print(attack_component == null)
		if attack_component != null && local_attack_time > 0:
			moving_next_turn = false
			#print("in here")
			local_attack_time -= 1
			if local_attack_time == 0:
				attack_component.attack()
				local_attack_time = attack_component.time_to_attack
				state = State.MOVING
		elif attack_component == null:
			state = State.MOVING	
	SignalBus.enemy_attack_received.emit()
