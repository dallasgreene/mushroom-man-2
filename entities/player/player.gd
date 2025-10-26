extends Node3D


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_forward"):
		attempt_move(Vector2(0, 1))
	elif Input.is_action_just_pressed("move_backward"):
		attempt_move(Vector2(0, -1))
	elif Input.is_action_just_pressed("move_left"):
		attempt_move(Vector2(1, 0))
	elif Input.is_action_just_pressed("move_right"):
		attempt_move(Vector2(-1, 0))


func attempt_move(direction: Vector2):
	position = Vector3(
		int(position.x) + (2 * int(direction.x)),
		position.y,
		int(position.z) + (2 * int(direction.y))
	)
