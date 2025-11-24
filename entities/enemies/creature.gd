extends CharacterBody3D
class_name Creature

var parent_room: Room
var is_player: bool
@export var health_component: HealthComponent
@export var attack_component: AttackComponent
@onready var creature_id: int = Global.get_next_available_creature_id()
