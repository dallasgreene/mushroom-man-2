class_name MoveableArea extends CSGBox3D


@export var the_shape: CollisionShape3D
@export var the_area: Plane


func _exit_tree():
	print("Node is leaving the scene tree.")
	# Perform cleanup or other actions here


func _ready() -> void:
	assert(rotation == Vector3.ZERO, "DO NOT ROTATE MoveableAreas!!")
	Moveable.register_moveable_area(self)
