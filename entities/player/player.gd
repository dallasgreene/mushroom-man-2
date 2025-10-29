extends Node3D
class_name Player

var end_basis: Basis
var moving = false
@export var current_room: Room

func _ready():
	Global.register_player(self)

func _physics_process(_delta: float) -> void:
	if !moving:
		if Input.is_action_just_pressed("move_forward"):
			attempt_move(0, -1)
		elif Input.is_action_just_pressed("move_backward"):
			attempt_move(0, 1)
		elif Input.is_action_just_pressed("move_left"):
			attempt_move(-1, 0)
		elif Input.is_action_just_pressed("move_right"):
			attempt_move(1, 0)
		elif Input.is_action_just_pressed("rotate_right"):
			end_basis = Basis(transform.basis.rotated(Vector3(0,1,0),-PI/2))
			moving = true
			create_tween().tween_method(rotate_player,transform.basis,end_basis,Global.ROTATE_SPEED).finished.connect(_on_rotating_finish)
		elif Input.is_action_just_pressed("rotate_left"):
			end_basis = Basis(transform.basis.rotated(Vector3(0,1,0),PI/2))
			moving = true
			create_tween().tween_method(rotate_player,transform.basis,end_basis,Global.ROTATE_SPEED).finished.connect(_on_rotating_finish)
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
	if desired_position.is_equal_approx(can_move_to_position):
		moving = true
		SignalBus.time_step.emit()
		create_tween().tween_method(move_player, position, desired_position, Global.MOVE_SPEED).finished.connect(_on_moving_finish)

func move_player(value: Vector3):
	position = value

func rotate_player(value: Basis):
	transform.basis = value

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
