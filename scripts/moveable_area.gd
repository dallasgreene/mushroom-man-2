class_name MoveableArea extends CSGBox3D

## Set to false to add pilars and other obstacles in a room
@export var can_move_into: bool = true


func _exit_tree():
	print("Node is leaving the scene tree.")
	# Perform cleanup or other actions here


func _ready() -> void:
	assert(rotation == Vector3.ZERO, "DO NOT ROTATE MoveableAreas!!")
	Moveable.register_moveable_area(self)
