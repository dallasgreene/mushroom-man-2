class_name Room extends Node3D


## Keep in mind that all positions in this pathfinding object are relative to this room,
## and need to be converted to global positions when used.
var pathfinding: AStar3D = null
## The ID used to identify this room
var room_id: int = -1
## Structure: { [x_coord]: { [z_coord]: Tile } }
var tile_states: Dictionary = {}


func _ready() -> void:
	init_pathfinding.call_deferred()
	room_id = Global.get_next_available_room_id()


func add_points_from_moveable_area(aggregator: Dictionary, move_area: MoveableArea) -> void:
	for x_index in range(
		roundi(move_area.global_position.x - (move_area.size.x / 2) + (float(Global.TILE_SIZE) / 2)),
		roundi(move_area.global_position.x + (move_area.size.x / 2)),
		Global.TILE_SIZE
	):
		if not aggregator.has(x_index):
			aggregator[x_index] = {}
		for z_index in range(
			roundi(move_area.global_position.z - (move_area.size.z / 2) + (float(Global.TILE_SIZE) / 2)),
			roundi(move_area.global_position.z + (move_area.size.z / 2)),
			Global.TILE_SIZE
		):
			aggregator[x_index][z_index] = -1


func add_connections_for_position(positive_points: Dictionary, x_coord: int, z_coord: int, curr_position_id: int) -> void:
	var left_pos_id = positive_points.get(x_coord - Global.TILE_SIZE, {}).get(z_coord, -1)
	var right_pos_id = positive_points.get(x_coord + Global.TILE_SIZE, {}).get(z_coord, -1)
	var forward_pos_id = positive_points.get(x_coord, {}).get(z_coord + Global.TILE_SIZE, -1)
	var back_pos_id = positive_points.get(x_coord, {}).get(z_coord - Global.TILE_SIZE, -1)
	for position_id in [left_pos_id, right_pos_id, forward_pos_id, back_pos_id]:
		if position_id != -1:
			pathfinding.connect_points(curr_position_id, position_id)


func init_pathfinding() -> void:
	if pathfinding != null:
		return
	var positive_points = {}
	var negative_points = {}
	for child_node in get_children():
		if child_node is MoveableArea:
			if child_node.can_move_into:
				add_points_from_moveable_area(positive_points, child_node)
			else:
				add_points_from_moveable_area(negative_points, child_node)
	# Remove the negative points from the moveable points
	for negative_x_coord in negative_points.keys():
		if positive_points.has(negative_x_coord):
			for negative_z_coord in negative_points[negative_x_coord].keys():
				positive_points[negative_x_coord].erase(negative_z_coord)
	# Register to globals that need the points data
	Minimaps.register_room(room_id, positive_points)
	TileState.register_room(room_id, self)
	# Create the Astar from the positive points
	var position_id = 0
	pathfinding = AStar3D.new()
	for x_coord in positive_points.keys():
		tile_states[x_coord] = {}
		for z_coord in positive_points[x_coord].keys():
			position_id = pathfinding.get_available_point_id()
			pathfinding.add_point(position_id, Vector3(x_coord, 0, z_coord))
			# positive_points is initialized to -1, then set here to the corresponding position ID
			# in the AStar pathfinding object.
			positive_points[x_coord][z_coord] = position_id
			tile_states[x_coord][z_coord] = Tile.new(room_id, position_id)
			add_connections_for_position(positive_points, x_coord, z_coord, position_id)


func move_entity(old_position: Vector3i, new_position: Vector3i, entity: Node3D) -> void:
	var prev_tile = get_tile(old_position.x, old_position.z)
	var new_tile = get_tile(new_position.x, new_position.z)
	pathfinding.set_point_disabled(prev_tile.astar_position_id, false)
	prev_tile.occupying_entity = null
	pathfinding.set_point_disabled(new_tile.astar_position_id, true)
	new_tile.occupying_entity = entity


func attempt_to_move_player(new_position: Vector3i) -> bool:
	var player_pos = Global.player.position
	var old_pos = Vector3i(roundi(player_pos.x), roundi(player_pos.y), roundi(player_pos.z))
	move_entity(old_pos, new_position, Global.player)
	return true


func get_tile(x_coord: int, z_coord: int) -> Tile:
	return tile_states[x_coord][z_coord]
