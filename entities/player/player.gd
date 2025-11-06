extends Creature
class_name Player

var end_rotation: Vector3
var moving = false
var waiting_for_enemies = false

func _ready():
	Global.register_player(self)
	SignalBus.enemies_finished_acting.connect(_on_enemies_finished_acting)
	var position_int = Vector3i(
		roundi(global_position.x),
		roundi(global_position.y),
		roundi(global_position.z),
	)
	tile_position = position_int

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
			pass

func attempt_move(forward_direction: int, lateral_direction: int):
	var desired_position = (
		position +
		(2 * lateral_direction) * transform.basis.z +
		(2 * forward_direction) * transform.basis.x
	)
	var can_move_to_position = current_room.pathfinding.get_point_position(
		current_room.pathfinding.get_closest_point(desired_position)
	)
	var desired_position_int = Vector3i(
		roundi(desired_position.x),
		roundi(desired_position.y),
		roundi(desired_position.z),
	)
	if desired_position.is_equal_approx(can_move_to_position):
		if not current_room.attempt_to_move_player(desired_position_int):
			return
		moving = true
		waiting_for_enemies = true
		tile_position = desired_position_int
		desired_position.y = %CameraPitch.global_position.y
		EnemyAction.enemies_take_turn()
		create_tween().tween_method(move_player, $CameraPitch.global_position, desired_position, Global.MOVE_SPEED).finished.connect(_on_moving_finish)
		
func move_player(value: Vector3):
	%CameraPitch.global_position = value

func rotate_player(value: Vector3):
	rotation_degrees = value

func _on_moving_finish():
	global_position = tile_position
	%CameraPitch.position = Vector3(0,2,0)
	moving = false
	position.x = roundf(position.x)
	position.y = roundf(position.y)
	position.z = roundf(position.z)
	SignalBus.player_moved.emit(tile_position)

func _on_rotating_finish():
	moving = false
	rotation_degrees.y = roundf(rotation_degrees.y)
	#print("current position: ", position)
	#print("path: ",current_room.pathfinding.get_point_path(current_room.pathfinding.get_closest_point(position), current_room.pathfinding.get_closest_point(Vector3(0,0,0))))


func _on_enemies_finished_acting() -> void:
	waiting_for_enemies = false
