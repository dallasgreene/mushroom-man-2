extends Creature
class_name Player

var end_rotation: Vector3
var moving = false
var waiting_for_enemies = false

@onready var collision_shape = %CollisionShape3D
var attack_dict:Dictionary[int,AttackData]
var basic_attack:AttackData 
var circle_attack:AttackData 
var cleave_attack:AttackData 
var cone_attack:AttackData 
var line_attack:AttackData

func _ready():
	creature_id = 0
	basic_attack = load("uid://dcg11ia5f61g1")
	circle_attack = load("uid://d3cq6sl20vjsp")
	cleave_attack = load("uid://ggv27lhwntyg")
	cone_attack = load("uid://dynpxwwmyndsm")
	line_attack = load("uid://ji78awr6rs5t")
	attack_dict[0]=basic_attack
	attack_dict[1]=circle_attack
	attack_dict[2]=cleave_attack
	attack_dict[3]=cone_attack
	attack_dict[4]=line_attack
	attack_component.attack_data = basic_attack
	is_player = true
	var current_parent = get_parent()
	while !current_parent is Room:
		current_parent = current_parent.get_parent()
	parent_room = current_parent
	if Global.player:
		Global.player.queue_free()
	Global.register_player(self)
	SignalBus.enemies_finished_acting.connect(_on_enemies_finished_acting)
	SignalBus.player_selected_attack.connect(_on_player_selected_attack)
	SignalBus.player_unselected_attack.connect(_on_player_unselected_attack)
	SignalBus.player_ready.emit()

func _physics_process(_delta: float) -> void:
	if !moving and !waiting_for_enemies:
		if Input.is_action_just_pressed("move_forward"):
			attempt_move(0, -1)
		elif Input.is_action_just_pressed("move_backward"):
			attempt_move(0, 1)
		elif Input.is_action_just_pressed("move_left"):
			attempt_move(-1, 0)
		elif Input.is_action_just_pressed("move_right"):
			attempt_move(1, 0)
		elif Input.is_action_just_pressed("rotate_right"):
			end_rotation.y = roundi(rotation_degrees.y-90)
			moving = true
			create_tween().tween_method(rotate_player,rotation_degrees,end_rotation,Global.ROTATE_SPEED).finished.connect(_on_rotating_finish)
		elif Input.is_action_just_pressed("rotate_left"):
			end_rotation.y = roundi(rotation_degrees.y+90)
			moving = true
			create_tween().tween_method(rotate_player,rotation_degrees,end_rotation,Global.ROTATE_SPEED).finished.connect(_on_rotating_finish)
		if Input.is_action_just_pressed("melee_attack"):
			%BladeSwingSound.play()
			attack_component.create_attack(parent_room,self,attack_component.attack_data)
			parent_room.attack_count_down(self)			
			SignalBus.enemies_take_turn.emit()

func attempt_move(forward_direction: int, lateral_direction: int):
	var desired_position = (
		position +
		(2 * lateral_direction) * transform.basis.z +
		(2 * forward_direction) * transform.basis.x
	)
	var can_move_to_position = parent_room.pathfinding.get_point_position(
		parent_room.pathfinding.get_closest_point(desired_position)
	)
	if desired_position.is_equal_approx(can_move_to_position):
		if not parent_room.attempt_to_move_player(Vector3i(
			roundi(desired_position.x),
			roundi(desired_position.y),
			roundi(desired_position.z),
		)):
			return
			
		#%CollisionShape3D.global_position = Vector3(desired_position.x, %CollisionShape3D.global_position.y, desired_position.z)
		moving = true
		waiting_for_enemies = true
		var temp:Vector3i = Vector3i(
			roundi(global_position.x),
			roundi(%CameraPitch.global_position.y),
			roundi(global_position.z))
			
		global_position = desired_position
		%CameraPitch.global_position = temp
		desired_position.y = %CameraPitch.global_position.y
		create_tween().tween_method(move_player, %CameraPitch.global_position, desired_position, Global.MOVE_SPEED).finished.connect(_on_moving_finish)
		SignalBus.enemies_take_turn.emit()

func move_player(value: Vector3):
	%CameraPitch.global_position = value
	%StepsSound.play()

func rotate_player(value: Vector3):
	rotation_degrees = value
	%TurnCamSound.play()

func _on_moving_finish():
	moving = false
	position.x = roundf(position.x)
	position.y = roundf(position.y)
	position.z = roundf(position.z)
	SignalBus.player_moved.emit(Vector3i(
		roundi(global_position.x),
		roundi(global_position.y),
		roundi(global_position.z),
	))

func _on_rotating_finish():
	moving = false
	rotation_degrees.y = roundf(rotation_degrees.y)
	#print("current position: ", position)
	#print("path: ",current_room.pathfinding.get_point_path(current_room.pathfinding.get_closest_point(position), current_room.pathfinding.get_closest_point(Vector3(0,0,0))))


func _on_enemies_finished_acting() -> void:
	waiting_for_enemies = false
	if parent_room.enemies_left<=0:
		SignalBus.change_level.emit()
	parent_room.minimap.redraw_minimap(parent_room.tile_states)


func _on_player_selected_attack(attack_index) -> void:
	var attacked_tile_coords = attack_component.get_attacked_tile_coords(parent_room, attack_dict[attack_index])
	parent_room.minimap.draw_player_attack(attacked_tile_coords)


func _on_player_unselected_attack() -> void:
	parent_room.minimap.clear_player_attack()


func _on_health_component_died() -> void:
	print("You are dead")


func _on_health_component_took_damage() -> void:
	%TakeDamageSound.play()
