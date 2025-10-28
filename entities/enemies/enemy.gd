extends Node3D
class_name Enemy
@onready var movement_component: MovementComponent = $MovementComponent
var parent_room: Room
var movement_step: bool = false

func _ready() -> void:
	SignalBus.time_step.connect(_movement_process)
	var current_parent = get_parent()
	while !current_parent is Room:
		current_parent = current_parent.get_parent()
	parent_room = current_parent
	

func _exit_tree() -> void:
	SignalBus.time_step.disconnect(_movement_process)

func _movement_process():
	movement_step = !movement_step
	if movement_component != null && movement_step:
		movement_component.move(parent_room, self)
