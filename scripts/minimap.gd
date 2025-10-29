class_name Minimap extends RefCounted

## Dictionary where 1st level keys are global x coordinates, and 2nd level keys
## are global z coordinates. The final value is the pixel position of that tile
## in the minimap texture.
var moveable_positions: Dictionary = {}
var base_image_texture: ImageTexture


## Returns the pixel position on the minimap texture that corresponds to the
## given grid coordinate in real space.
func get_pixel_position_from_grid(grid_position: Vector3i) -> Vector2i:
	return moveable_positions[grid_position.x][grid_position.z]


func _init(position_dict: Dictionary) -> void:
	var x_min = min.callv(position_dict.keys())
	var x_max = max.callv(position_dict.keys())
	var y_min = position_dict[position_dict.keys()[0]].keys()[0]
	var y_max = y_min
	for x_coord in position_dict.keys():
		y_min = min(y_min, min.callv(position_dict[x_coord].keys()))
		y_max = max(y_max, max.callv(position_dict[x_coord].keys()))
	
	var x_size = x_max - x_min + Global.TILE_SIZE
	var y_size = y_max - y_min + Global.TILE_SIZE
	var resize_factor = min(
		floori(float(Minimaps.MINIMAP_SIZE.x) / x_size),
		floori(float(Minimaps.MINIMAP_SIZE.y) / y_size),
	)
	x_size *= resize_factor
	y_size *= resize_factor

	var room_image = Image.create_empty(x_size, y_size, false, Image.FORMAT_RGBA8)
	for x_coord in position_dict.keys():
		moveable_positions[x_coord] = {}
		for y_coord in position_dict[x_coord].keys():
			var rect_position = Vector2i(x_coord - x_min, y_coord - y_min)
			rect_position *= resize_factor
			moveable_positions[x_coord][y_coord] = rect_position
			var rect_to_fill = Rect2i(
				rect_position,
				Vector2i(Global.TILE_SIZE, Global.TILE_SIZE) * resize_factor
			)
			room_image.fill_rect(rect_to_fill, Color.WHITE)
	#room_image.resize(x_size * resize_factor, y_size * resize_factor, Image.INTERPOLATE_NEAREST)
	base_image_texture = ImageTexture.create_from_image(room_image)
