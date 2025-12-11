class_name Minimap extends Node2D
## Represents the minimap for one specific room.

const BACKGROUND_TILESET = preload("uid://f5wth1oaplhs")
const CREATURE_TILESET = preload("uid://dg003lr252uxa")
const ATTACK_TILESET = preload("uid://clsw0etoc8qua")

# Atlas coords for the attack zone sprite sheet
const TOP_ONLY = Vector2i(0, 0)
const TOP_SW_DOT = Vector2i(1, 0)
const TOP_SE_DOT = Vector2i(2, 0)
const TOP_SW_SE_DOT = Vector2i(3, 0)
const TOP_LEFT = Vector2i(4, 0)
const TOP_LEFT_SE_DOT = Vector2i(5, 0)
const TOP_LEFT_BOTTOM = Vector2i(6, 0)
const TOP_BOTTOM = Vector2i(7, 0)
const ALL_SIDES = Vector2i(8, 0)
const NW_DOT = Vector2i(9, 0)
const NW_NE_DOT = Vector2i(10, 0)
const NE_SW_DOT = Vector2i(11, 0)
const NW_NE_SW_DOT = Vector2i(12, 0)
const ALL_DOTS = Vector2i(13, 0)
const EMPTY = Vector2i(14, 0)

# Atlas coords for creatures
const PLAYER = Vector2i(0, 0)
const ENEMY = Vector2i(1, 0)

# Source IDs for tile sets
const BACKGROUND_SOURCE_ID: int = 0
const ATTACK_SOURCE_ID: int = 2
const CREATURE_SOURCE_ID: int = 6

# Rotations for attack zone tiles
enum TileTransform {
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

const ATTACK_MODULATE_COLORS = [
	Color(0.0, 0.784, 0.784, 0.5),
	Color(0.588, 0.294, 0.294, 0.5),
	Color(0.605, 0.196, 0.569, 0.5),
	Color(0.3, 0.339, 0.752, 0.5)
]

## Dictionary where 1st level keys are global world x coordinates, and 2nd level
## keys are global world z coordinates. The final value is a Vector2i
## representing the X and Y coordinates of the tile in the minimap tilemap
var moveable_positions: Dictionary = {}
var background_layer: TileMapLayer = null
var creature_layer: TileMapLayer = null
var player_attack_layer: TileMapLayer = null
## Mapping of creature_id to the corresponding tilemap layer for that creature's
## attack indicators
var enemy_attack_layers: Dictionary[int, TileMapLayer] = {}
var next_available_modulate_color: int = 0


## Returns the X and Y coordinates of the tile in the minimap tilemap, given the
## grid position in the 3D world.
func get_tile_cordinate_from_grid_position(grid_position: Vector3i) -> Vector2i:
	return moveable_positions[grid_position.x][grid_position.z]


func create_basic_tilemap_layer() -> TileMapLayer:
	var new_layer = TileMapLayer.new()
	new_layer.collision_enabled = false
	new_layer.navigation_enabled = false
	add_child(new_layer)
	return new_layer


func _init(position_dict: Dictionary, enemies_in_room: Array[Enemy]) -> void:
	background_layer = create_basic_tilemap_layer()
	background_layer.tile_set = BACKGROUND_TILESET
	creature_layer = create_basic_tilemap_layer()
	creature_layer.tile_set = CREATURE_TILESET
	player_attack_layer = create_basic_tilemap_layer()
	player_attack_layer.tile_set = ATTACK_TILESET

	var x_min = min.callv(position_dict.keys())
	var y_min = position_dict[position_dict.keys()[0]].keys()[0]
	for x_coord in position_dict.keys():
		y_min = min(y_min, min.callv(position_dict[x_coord].keys()))

	for x_coord in position_dict.keys():
		if position_dict[x_coord].size() > 0:
			moveable_positions[x_coord] = {}
		for y_coord in position_dict[x_coord].keys():
			moveable_positions[x_coord][y_coord] = Vector2i(
				roundi((float(x_coord - x_min) / Global.TILE_SIZE)),
				roundi((float(y_coord - y_min) / Global.TILE_SIZE))
			)
			background_layer.set_cell(
				moveable_positions[x_coord][y_coord],
				BACKGROUND_SOURCE_ID,
				Vector2i(0, 0)
			)

	for enemy in enemies_in_room:
		enemy_attack_layers[enemy.creature_id] = create_basic_tilemap_layer()
		enemy_attack_layers[enemy.creature_id].tile_set = ATTACK_TILESET
		var tile_coord = get_tile_cordinate_from_grid_position(Vector3i(
			roundi(enemy.position.x), 0, roundi(enemy.position.z)
		))
		creature_layer.set_cell(tile_coord, CREATURE_SOURCE_ID, ENEMY)

## Note that attacked_tile_coords is in minimap coordinates, not grid coordinates
func draw_attack(creature_id: int, attacked_tile_coords: Dictionary) -> void:
	var target_layer: TileMapLayer = player_attack_layer
	if creature_id != 0:
		if not enemy_attack_layers.has(creature_id):
			enemy_attack_layers[creature_id] = create_basic_tilemap_layer()
			enemy_attack_layers[creature_id].tile_set = ATTACK_TILESET
		target_layer = enemy_attack_layers[creature_id]
	if target_layer.modulate == Color.WHITE:
		target_layer.modulate = ATTACK_MODULATE_COLORS[next_available_modulate_color]
		next_available_modulate_color += 1

	for x_coord in attacked_tile_coords.keys():
		for y_coord in attacked_tile_coords[x_coord].keys():
			var dots = { "nw": true, "ne": true, "sw": true, "se": true }
			var num_dots = 4
			var lines = { "top": true, "bottom": true, "left": true, "right": true }
			var num_lines = 4
			if attacked_tile_coords[x_coord].has(y_coord - 1):
				lines.top = false
				num_lines -= 1
			if attacked_tile_coords[x_coord].has(y_coord + 1):
				lines.bottom = false
				num_lines -= 1
			if attacked_tile_coords.has(x_coord + 1) and attacked_tile_coords[x_coord + 1].has(y_coord):
				lines.right = false
				num_lines -= 1
			if attacked_tile_coords.has(x_coord - 1) and attacked_tile_coords[x_coord - 1].has(y_coord):
				lines.left = false
				num_lines -= 1
			if attacked_tile_coords.has(x_coord + 1) and attacked_tile_coords[x_coord + 1].has(y_coord - 1):
				dots.ne = false
				num_dots -= 1
			if attacked_tile_coords.has(x_coord - 1) and attacked_tile_coords[x_coord - 1].has(y_coord - 1):
				dots.nw = false
				num_dots -= 1
			if attacked_tile_coords.has(x_coord + 1) and attacked_tile_coords[x_coord + 1].has(y_coord + 1):
				dots.se = false
				num_dots -= 1
			if attacked_tile_coords.has(x_coord - 1) and attacked_tile_coords[x_coord - 1].has(y_coord + 1):
				dots.sw = false
				num_dots -= 1
			if num_lines == 4:
				target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, ALL_SIDES)
			elif num_lines == 3:
				var tile_rotation = 0
				if not lines.top:
					tile_rotation = TileTransform.ROTATE_270
				if not lines.bottom:
					tile_rotation = TileTransform.ROTATE_90
				if not lines.left:
					tile_rotation = TileTransform.ROTATE_180
				target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, TOP_LEFT_BOTTOM, tile_rotation)
			elif num_lines == 2:
				if lines.top and lines.bottom:
					target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, TOP_BOTTOM)
				elif lines.left and lines.right:
					target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, TOP_BOTTOM, TileTransform.ROTATE_90)
				else:
					var opposite_dot = ""
					if lines.top:
						opposite_dot = "s" + opposite_dot
					if lines.bottom:
						opposite_dot = "n" + opposite_dot
					if lines.left:
						opposite_dot += "e"
					if lines.right:
						opposite_dot += "w"

					var atlas_coords = TOP_LEFT
					if dots[opposite_dot]:
						atlas_coords = TOP_LEFT_SE_DOT

					var tile_rotation = 0
					if opposite_dot == "sw":
						tile_rotation = TileTransform.ROTATE_90
					if opposite_dot == "nw":
						tile_rotation = TileTransform.ROTATE_180
					if opposite_dot == "ne":
						tile_rotation = TileTransform.ROTATE_270
					target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, atlas_coords, tile_rotation)
			elif num_lines == 1:
				var atlas_coords = TOP_ONLY
				var tile_rotation = 0
				if lines.top:
					if dots.sw and dots.se:
						atlas_coords = TOP_SW_SE_DOT
					elif dots.sw:
						atlas_coords = TOP_SW_DOT
					elif dots.se:
						atlas_coords = TOP_SE_DOT
				if lines.bottom:
					tile_rotation = TileTransform.ROTATE_180
					if dots.ne and dots.nw:
						atlas_coords = TOP_SW_SE_DOT
					elif dots.ne:
						atlas_coords = TOP_SW_DOT
					elif dots.nw:
						atlas_coords = TOP_SE_DOT
				if lines.left:
					tile_rotation = TileTransform.ROTATE_270
					if dots.se and dots.ne:
						atlas_coords = TOP_SW_SE_DOT
					elif dots.se:
						atlas_coords = TOP_SW_DOT
					elif dots.ne:
						atlas_coords = TOP_SE_DOT
				if lines.right:
					tile_rotation = TileTransform.ROTATE_90
					if dots.nw and dots.sw:
						atlas_coords = TOP_SW_SE_DOT
					elif dots.nw:
						atlas_coords = TOP_SW_DOT
					elif dots.sw:
						atlas_coords = TOP_SE_DOT
				target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, atlas_coords, tile_rotation)
			else:
				if num_dots == 4:
					target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, ALL_DOTS)
				elif num_dots == 3:
					var tile_rotation = 0
					if not dots.sw:
						tile_rotation = TileTransform.ROTATE_90
					if not dots.nw:
						tile_rotation = TileTransform.ROTATE_180
					if not dots.ne:
						tile_rotation = TileTransform.ROTATE_270
					target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, NW_NE_SW_DOT, tile_rotation)
				elif num_dots == 2:
					if dots.ne and dots.sw:
						target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, NE_SW_DOT)
					elif dots.nw and dots.se:
						target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, NE_SW_DOT, TileTransform.ROTATE_90)
					else:
						var tile_rotation = 0
						if dots.ne and dots.se:
							tile_rotation = TileTransform.ROTATE_90
						if dots.se and dots.sw:
							tile_rotation = TileTransform.ROTATE_180
						if dots.sw and dots.nw:
							tile_rotation = TileTransform.ROTATE_270
						target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, NW_NE_DOT, tile_rotation)
				elif num_dots == 1:
					var tile_rotation = 0
					if dots.ne:
						tile_rotation = TileTransform.ROTATE_90
					if dots.se:
						tile_rotation = TileTransform.ROTATE_180
					if dots.sw:
						tile_rotation = TileTransform.ROTATE_270
					target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, NW_DOT, tile_rotation)
				else:
					target_layer.set_cell(Vector2i(x_coord, y_coord), ATTACK_SOURCE_ID, EMPTY)


func redraw_minimap(tile_states: Dictionary) -> void:
	# Clear all the previous data
	creature_layer.clear()
	player_attack_layer.clear()
	for enemy_id in enemy_attack_layers.keys():
		enemy_attack_layers[enemy_id].clear()

	var player_attack = {}
	var attacks = {}
	for x_coord in tile_states.keys():
		for z_coord in tile_states[x_coord].keys():
			var tile_coord = get_tile_cordinate_from_grid_position(Vector3i(
				x_coord, 0, z_coord
			))
			var tile_state: Tile = tile_states[x_coord][z_coord]
			if tile_state.occupying_entity != null:
				if tile_state.occupying_entity is Creature:
					if tile_state.occupying_entity.is_player:
						creature_layer.set_cell(tile_coord, CREATURE_SOURCE_ID, PLAYER)
					else:
						creature_layer.set_cell(tile_coord, CREATURE_SOURCE_ID, ENEMY)
				else:
					pass # TODO add if non-creature entities are allowed
			for attacking_creature in tile_state.attack_queue.keys():
				if attacking_creature.is_player:
					player_attack.get_or_add(tile_coord.x, {})[tile_coord.y] = true
				else:
					attacks.get_or_add(attacking_creature.creature_id, {}).get_or_add(tile_coord.x, {})[tile_coord.y] = true
	if not player_attack.is_empty():
		draw_attack(0, player_attack)
	if not attacks.is_empty():
		for attacker_id in attacks.keys():
			draw_attack(attacker_id, attacks[attacker_id])


func draw_player_attack(attacked_tile_grid_coords: Dictionary) -> void:
	player_attack_layer.clear()
	var attacked_tile_minimap_coords = {}
	for x_coord in attacked_tile_grid_coords.keys():
		for z_coord in attacked_tile_grid_coords[x_coord].keys():
			var tile_coord = get_tile_cordinate_from_grid_position(Vector3i(
				x_coord, 0, z_coord
			))
			attacked_tile_minimap_coords.get_or_add(tile_coord.x, {})[tile_coord.y] = true
	draw_attack(0, attacked_tile_minimap_coords)


func clear_player_attack() -> void:
	player_attack_layer.clear()
