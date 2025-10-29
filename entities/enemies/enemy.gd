extends CharacterBody3D
class_name Enemy
var parent_room: Room
var moving_next_turn: bool = false
var state: State
@export var attack_component: AttackComponent
@export var movement_component: EnemyMovementComponent

enum State{
	MOVING,
	ATTACKING
}

func _ready() -> void:
	SignalBus.time_step.connect(_turn_process)
	var current_parent = get_parent()
	while !current_parent is Room:
		current_parent = current_parent.get_parent()
	parent_room = current_parent
	

func _exit_tree() -> void:
	SignalBus.time_step.disconnect(_turn_process)

func _turn_process():
	match state:
		State.ATTACKING:
			if attack_component != null && attack_component.time_to_attack >0:
				moving_next_turn = false
				attack_component.time_to_attack -= 1
				if attack_component.time_to_attack == 0:
					attack_component.attack()
					state = State.MOVING
			elif attack_component != null && attack_component.time_to_attack == 0:
				attack_component.attack_type = AttackComponent.AttackType.CONE
				attack_component.distance = 2
				attack_component.enemy_attack = true
				attack_component.time_to_attack = 3
				attack_component.create_attack()
			elif attack_component == null:
				state = State.MOVING	
		State.MOVING:
			if movement_component != null && moving_next_turn:
				var path = movement_component.move(parent_room, self)
				if attack_component!= null && ((path.size() <= attack_component.distance + 1) || (path.size() == 1 && attack_component.attack_type == AttackComponent.AttackType.CLEAVE)):
					state = State.ATTACKING
			moving_next_turn = !moving_next_turn
		_:
			print("state machine missing state for ", self.to_string())
