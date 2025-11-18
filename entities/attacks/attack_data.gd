extends Resource
class_name AttackData

@export_range(0,100) var time_to_attack: int
@export var damage: int
@export var linger_time: int
@export var is_enemy_attack: bool
@export_range(1,100) var distance: int
@export var attack_type: AttackType
var remaining_time_in_attack: int

enum AttackType{
	CONE,
	LINE,
	CLEAVE,
	CIRCLE
}
	
func _to_string() -> String:
	var string = "Time to attack: %s \n Damage: %s \n Linger Time: %s \n Is Enemy Attack: %s \n Distance: %s" % [time_to_attack,damage,linger_time,is_enemy_attack, distance]
	return string
