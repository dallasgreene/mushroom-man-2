extends Node3D

func _ready():
	SignalBus.change_level.connect(_change_level)

func _change_level():
	var child_list = get_children()
	for child in child_list:
		if child is Room:
			if child.next_room_value != Global.Rooms.NONE:
				print(child.next_room_value)
				persist_player()
				var packed_scene = load(Global.rooms[child.next_room_value])
				Global.player.queue_free()
				remove_child(child)
				add_child(packed_scene.instantiate())
				
				set_up_player()
				
				var minimap_children = Minimaps.parent_viewport.get_children()
				for minimap_child in minimap_children:
					if minimap_child is Minimap:
						Minimaps.parent_viewport.remove_child(minimap_child)

func persist_player():
	PlayerData.current_health = Global.player.health_component.current_health
	PlayerData.max_health = Global.player.health_component.max_health

func set_up_player():
	Global.player.health_component.current_health = PlayerData.current_health
	Global.player.health_component.max_health = PlayerData.max_health
			
