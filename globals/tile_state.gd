extends Node


## References to the actual room objects
var rooms: Dictionary[int, Room] = {}
var current_room: int = 0


func register_room(room_id: int, room: Room) -> void:
	rooms[room_id] = room
