extends CharacterBody3D
class_name Enemy
var parent_room: Room
var moving_next_turn: bool = false
var state: State
var path
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
				attack_component.create_attack()
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
						print("path size: ", path.size())
						print("path", path)
						print("attack_component.distance: ", attack_component.distance )
						state = State.ATTACKING
						path = null
		_:
			print("state machine missing state for ", self.to_string())
