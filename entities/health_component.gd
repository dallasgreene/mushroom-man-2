extends Node3D
class_name HealthComponent

@export_range(1,100) var max_health: int
var current_health: int

func _ready() -> void:
	current_health = max_health
	
func take_damage(damage:int):
	print("Health was ", current_health)
	current_health -= damage
	print("Current Health is ", current_health)
	if current_health <= 0:
		get_parent().queue_free()
