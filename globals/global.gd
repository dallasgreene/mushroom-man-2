extends Node


const ROTATE_SPEED = 0.2
const MOVE_SPEED = 0.2
const ENEMY_MOVE_SPEED = 0.1
## The size of a tile in meters
const TILE_SIZE: int = 2

var player: Player
var next_room_id: int = 0
var next_attack_id: int = 0


func register_player(player_input:Player):
	self.player = player_input


## Every room should call this on _ready to get its ID
func get_next_available_room_id() -> int:
	next_room_id += 1
	return next_room_id - 1


## When an entity attacks, it should get an attack ID and then pass it along
## when queuing the attack in the tile state.
func get_next_available_attack_id() -> int:
	next_attack_id += 1
	return next_attack_id - 1
