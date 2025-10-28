extends Node


const ROTATE_SPEED = 0.2
const MOVE_SPEED = 0.2
const ENEMY_MOVE_SPEED = 0.1

var player: Player

func register_player(player_input:Player):
	self.player = player_input
