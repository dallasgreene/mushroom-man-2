extends Creature
class_name Enemy
var moving_next_turn: bool = false
var state: State = State.IDLE
var path
var local_attack_time
@export var movement_component: EnemyMovementComponent
@onready var sprite = %Sprite3D
@export var attack_data: AttackData

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
	parent_room.enemies_left += 1
	local_attack_time = attack_component.attack_data.time_to_attack + 1
	await parent_room.pathfinding_initialized
	parent_room.move_creature(global_position,global_position,self)
	parent_room.minimap.redraw_minimap(parent_room.tile_states)

func _exit_tree() -> void:
	if attack_component != null && SignalBus.enemy_attack_start.is_connected(_enemy_attack_start):
		SignalBus.enemy_attack_start.disconnect(_enemy_attack_start)
	if movement_component != null && SignalBus.enemy_movement_start.is_connected(_enemy_movement_start):
		SignalBus.enemy_movement_start.disconnect(_enemy_movement_start)

func _enemy_movement_start():
	if state == State.MOVING:
		if movement_component != null:
			path = movement_component.get_navigation_path(parent_room, self)
			if moving_next_turn:
				path = movement_component.move(parent_room, self)
				path = path.slice(1,path.size())
				if %MoveSound:
					%MoveSound.play()
			else:
				path = movement_component.get_navigation_path(parent_room, self)
				path = path.slice(1,path.size())
				movement_component.enemy_look_at()
			moving_next_turn = !moving_next_turn
			if attack_component!= null:
				if path != null && ((path.size() <= attack_component.attack_data.distance)):
					state = State.ATTACKING
					path = null
					attack_component.create_attack(parent_room,self,attack_component.attack_data)
	SignalBus.enemy_movement_received.emit()

func _enemy_attack_start():
	if state == State.ATTACKING:
		print(global_position)
		if attack_component != null && local_attack_time > 0:
			if attack_data.time_to_attack + 1 == local_attack_time:
				if %AttackStartSound:
					%AttackStartSound.play()
				if %AttackLoopSound:
					%AttackLoopSound.play()
			local_attack_time -= 1
			parent_room.attack_count_down(self)
			if local_attack_time == 0:
				local_attack_time = attack_component.attack_data.time_to_attack + 1
				if %AttackFireSound:
					%AttackFireSound.play()
				if %AttackLoopSound:
					%AttackLoopSound.stop()
				state = State.MOVING
		elif attack_component == null:
			state = State.MOVING	
	SignalBus.enemy_attack_received.emit()


func _on_health_component_died() -> void:
	if attack_component != null:
		SignalBus.enemy_attack_start.disconnect(_enemy_attack_start)
	if movement_component != null:
		SignalBus.enemy_movement_start.disconnect(_enemy_movement_start)
	parent_room.creature_died(self)
	#I am doing this for now because it sounds better to hear the hit sound, but as it stands
	#if the enemy dies so does the stream player so i am keeping the enemy in until the sound finishes.
	#We can talk about this in discord, because this probably isnt the way we want to do it?
	if %TakeDamageSound:
		await %TakeDamageSound.finished
	queue_free()


func _on_health_component_took_damage() -> void:
	if %TakeDamageSound:
		%TakeDamageSound.play()
