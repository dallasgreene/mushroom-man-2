extends Node


var MINIMAP_SIZE: Vector2i = Vector2i.ZERO

var parent_viewport: SubViewport = null
var viewport_camera: Camera2D = null
var minimap_sprite: Sprite2D = null
var player_sprite: Sprite2D = null
var attack_sprites_root: Node2D = null

var room_minimaps: Dictionary[int, Minimap] = {}
var current_minimap: int = 0


func _ready() -> void:
	SignalBus.player_moved.connect(_on_player_moved)
	SignalBus.enemies_finished_acting.connect(update_attacks_on_minimap)


func register_parent_viewport(new_view: SubViewport) -> void:
	parent_viewport = new_view
	MINIMAP_SIZE = Vector2i(roundi(parent_viewport.size.x), roundi(parent_viewport.size.y))
	viewport_camera = Camera2D.new()
	parent_viewport.add_child(viewport_camera)
	minimap_sprite = Sprite2D.new()
	minimap_sprite.centered = false
	minimap_sprite.position = Vector2(-1 * float(MINIMAP_SIZE.x) / 2, -1 * float(MINIMAP_SIZE.y) / 2)
	parent_viewport.add_child(minimap_sprite)
	player_sprite = Sprite2D.new()
	player_sprite.texture = load("uid://6ybplxlys1eq")
	player_sprite.centered = false
	minimap_sprite.add_child(player_sprite)
	attack_sprites_root = Node2D.new()
	minimap_sprite.add_child(attack_sprites_root)


func create_room_minimap_texture(room_id: int, position_dict: Dictionary) -> int:
	var new_minimap = Minimap.new(position_dict)
	room_minimaps[room_id] = new_minimap
	minimap_sprite.texture = new_minimap.base_image_texture
	return room_minimaps.size() - 1


func register_room(room_id: int, position_dict: Dictionary) -> void:
	return create_room_minimap_texture(room_id, position_dict)


func _on_player_moved(new_position: Vector3i) -> void:
	var pixel_pos = room_minimaps[current_minimap].get_pixel_position_from_grid(new_position)
	player_sprite.position = pixel_pos


func update_attacks_on_minimap() -> void:
	var room = Global.player.parent_room
	for prev_attack_sprite in attack_sprites_root.get_children():
		prev_attack_sprite.queue_free()
	var tile_size = room_minimaps[room.room_id].tile_pixel_size
	for x_coord in room.tile_states:
		for z_coord in room.tile_states[x_coord]:
			var tile = room.get_tile(x_coord, z_coord)
			#print(x_coord, "  ", z_coord, "  ", str(tile.attack_queue))
			if not tile.attack_queue.is_empty():
				var pixel_pos = room_minimaps[room.room_id].get_pixel_position_from_grid(Vector3i(x_coord, 0, z_coord))
				var attack_sprite = Sprite2D.new()
				attack_sprite.texture = load("uid://dfwy765b3r78w")
				attack_sprite.centered = false
				attack_sprite.position = pixel_pos
				attack_sprite.scale = Vector2(
					float(tile_size) / attack_sprite.texture.get_width(),
					float(tile_size) / attack_sprite.texture.get_height(),
				)
				attack_sprite.centered = false
				attack_sprites_root.add_child(attack_sprite)
