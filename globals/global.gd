extends Node


const ROTATE_SPEED = 0.2
const MOVE_SPEED = 0.2
const ENEMY_MOVE_SPEED = 0.1
## The size of a tile in meters
const TILE_SIZE: int = 2

var player: Player
var hotbar: Hotbar
var next_room_id: int = 0
var next_creature_id: int = 1 # starts at 1 because player is always 0

enum Rooms {
	ROOM_1,
	ROOM_2
}

var rooms: Dictionary = {
	Rooms.ROOM_1: "uid://iadm6qir1suj",
	Rooms.ROOM_2: "uid://b1gx1q2pnj253"
}


func register_player(player_input: Player):
	self.player = player_input


func register_hotbar(hotbar_input: Hotbar) -> void:
	hotbar = hotbar_input


## Every room should call this on _ready to get its ID
func get_next_available_room_id() -> int:
	next_room_id += 1
	return next_room_id - 1


## Every creature should call this on _ready to get its ID
func get_next_available_creature_id() -> int:
	next_creature_id += 1
	return next_creature_id - 1
