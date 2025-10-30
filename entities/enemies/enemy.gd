extends CharacterBody3D
class_name Enemy
var parent_room: Room
var moving_next_turn: bool = false
var state: State
var path
var local_attack_time
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
	local_attack_time = attack_component.time_to_attack
	

func _exit_tree() -> void:
	SignalBus.time_step.disconnect(_turn_process)

func _turn_process():
	print(State.keys()[state])
	match state:
		State.ATTACKING:
			print(attack_component == null)
			if attack_component != null && attack_component.time_to_attack >0:
				moving_next_turn = false
				print("in here")
				attack_component.time_to_attack -= 1
				if attack_component.time_to_attack == 0:
					attack_component.attack()
					attack_component.time_to_attack = local_attack_time
					state = State.MOVING
			elif attack_component == null:
				state = State.MOVING	
		State.MOVING:
			if movement_component != null:
				if moving_next_turn:
					path = movement_component.move(parent_room, self)
					print("path size: ", path.size())
					print("attack_component.distance: ", attack_component.distance )
				moving_next_turn = !moving_next_turn
				if attack_component!= null:
					if path != null && ((path.size()-1 <= attack_component.distance) || (path.size()+1 == 1 && attack_component.attack_type == AttackComponent.AttackType.CLEAVE)):
						state = State.ATTACKING
						path = null
						attack_component.create_attack()
						print(AttackComponent.AttackType.keys()[attack_component.attack_type])
		_:
			print("state machine missing state for ", self.to_string())
