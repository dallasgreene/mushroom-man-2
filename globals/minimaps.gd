extends Node


var MINIMAP_SIZE: Vector2i = Vector2i.ZERO

var parent_viewport: SubViewport = null
var viewport_camera: Camera2D = null
var minimap_sprite: Sprite2D = null
var player_sprite: Sprite2D = null

var room_minimaps: Array[Minimap] = []
var current_minimap: int = 0
#var global_map_texture: ImageTexture = null
#var global_map_image: Image = Image.new()


func _ready() -> void:
	SignalBus.player_moved.connect(_on_player_moved)


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


func create_room_minimap_texture(position_dict: Dictionary) -> int:
	var new_minimap = Minimap.new(position_dict)
	room_minimaps.push_back(new_minimap)
	minimap_sprite.texture = new_minimap.base_image_texture
	return room_minimaps.size() - 1


func register_room(position_dict: Dictionary) -> int:
	return create_room_minimap_texture(position_dict)


func _on_player_moved(new_position: Vector3i) -> void:
	print(str(new_position))
	var pixel_pos = room_minimaps[current_minimap].get_pixel_position_from_grid(new_position)
	print(str(pixel_pos))
	player_sprite.position = pixel_pos
