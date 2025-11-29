extends Node


var MINIMAP_SIZE: Vector2i = Vector2i.ZERO
var MINIMAP_CENTER: Vector2 = Vector2.ZERO

var parent_viewport: SubViewport = null
var viewport_camera: Camera2D = null

var current_room: Room = null


func _ready() -> void:
	SignalBus.player_moved.connect(_on_player_moved)


func register_parent_viewport(new_view: SubViewport) -> void:
	parent_viewport = new_view
	MINIMAP_SIZE = Vector2i(roundi(parent_viewport.size.x), roundi(parent_viewport.size.y))
	MINIMAP_CENTER = Vector2(-1 * float(MINIMAP_SIZE.x) / 2, -1 * float(MINIMAP_SIZE.y) / 2)
	viewport_camera = Camera2D.new()
	parent_viewport.add_child(viewport_camera)


func _on_entered_room(room: Room) -> void:
	current_room = room
	set_minimap_to_viewport.call_deferred()


func set_minimap_to_viewport() -> void:
	current_room.minimap.position = MINIMAP_CENTER
	parent_viewport.add_child(current_room.minimap)


func _on_player_moved(_new_position: Vector3i) -> void:
	#current_room.minimap.redraw_minimap(current_room.tile_states)
	# TODO center minimap around player position
	pass
