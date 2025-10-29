extends Node


const ROTATE_SPEED = 0.2
const MOVE_SPEED = 0.2
const ENEMY_MOVE_SPEED = 0.1
## The size of a tile in meters
const TILE_SIZE: int = 2

var player: Player

func register_player(player_input:Player):
	self.player = player_input
