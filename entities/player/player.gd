extends Node3D


var rotate_speed = .2
var end_basis: Basis
var moving = false
		
func _physics_process(_delta: float) -> void:
	if !moving:
		if Input.is_action_just_pressed("move_forward"):
			attempt_move(Vector2(0, 1))
		elif Input.is_action_just_pressed("move_backward"):
			attempt_move(Vector2(0, -1))
		elif Input.is_action_just_pressed("move_left"):
			attempt_move(Vector2(1, 0))
		elif Input.is_action_just_pressed("move_right"):
			attempt_move(Vector2(-1, 0))
		elif Input.is_action_just_pressed("rotate_right"):
			end_basis = Basis(transform.basis.rotated(Vector3(0,1,0),-PI/2))
			moving = true
			create_tween().tween_method(rotate_player,transform.basis,end_basis,rotate_speed).finished.connect(_on_moving_finish)
		elif Input.is_action_just_pressed("rotate_left"):
			end_basis = Basis(transform.basis.rotated(Vector3(0,1,0),PI/2))
			moving = true
			create_tween().tween_method(rotate_player,transform.basis,end_basis,rotate_speed).finished.connect(_on_moving_finish)
		if Input.is_action_just_pressed("melee_attack"):
			pass

func attempt_move(direction: Vector2):
	position = Vector3(
		int(position.x) + (2 * int(direction.x)),
		position.y,
		int(position.z) + (2 * int(direction.y))
	)		

func rotate_player(value: Basis):
	transform.basis = value

func _on_moving_finish():
	moving = false
	rotation_degrees.y = roundf(rotation_degrees.y)
	print(rotation_degrees)
	
