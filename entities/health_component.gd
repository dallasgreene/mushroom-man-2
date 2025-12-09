extends Node3D
class_name HealthComponent

@export_range(1, 100) var max_health: int
@export var display_healthbar: bool = true
var current_health: int
@onready var player_take_damage = $Player_TakeDamage

var health_display_bar: ProgressBar

@onready var slime_takedamage = $"Slime_Take Damage"

signal died

func _ready() -> void:
	current_health = max_health
	if display_healthbar:
		health_display_bar = %ProgressBar
		health_display_bar.max_value = max_health
		health_display_bar.value = current_health
	else:
		$Sprite3D.queue_free()
		$SubViewport.queue_free()


func take_damage(damage: int):
	print("Health was ", current_health)
	current_health -= damage
	print("Current Health is ", current_health)
	health_display_bar.value = max(0, current_health)
	player_take_damage.play()
	if current_health <= 0:
		died.emit()
