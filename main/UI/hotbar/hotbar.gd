class_name Hotbar extends Control


var hotbar_slots: Array[HotbarSlot] = []
var active_index: int = 0
var currently_selected: int = -1


func _ready() -> void:
	for hbox_child in $MarginContainer/HBoxContainer.get_children():
		if hbox_child is HotbarSlot:
			hbox_child.slot_id = hotbar_slots.size()
			hotbar_slots.push_back(hbox_child)
	hotbar_slots[active_index].hover()
	SignalBus.player_moved.connect(_on_player_moved)
	SignalBus.player_ready.connect(_on_player_ready)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hotbar_left"):
		update_hovered_slot(posmod((active_index - 1), hotbar_slots.size()))
	elif Input.is_action_just_pressed("hotbar_right"):
		update_hovered_slot(posmod((active_index + 1), hotbar_slots.size()))
	elif Input.is_action_just_pressed("hotbar_select"):
		if currently_selected >= 0:
			hotbar_slots[currently_selected].unselect()
		if active_index == currently_selected:
			currently_selected = -1
			return
		hotbar_slots[active_index].select()
		currently_selected = active_index


func update_hovered_slot(new_index: int) -> void:
	hotbar_slots[active_index].unhover()
	active_index = new_index
	hotbar_slots[active_index].hover()
	if Global.player.attack_dict.has(active_index):
		Global.player.attack_component.attack_data = Global.player.attack_dict[active_index]
	else:
		Global.player.attack_component.attack_data = Global.player.attack_dict[0]


func _on_player_moved(_new_position: Vector3i) -> void:
	if currently_selected >= 0:
		hotbar_slots[currently_selected].unselect()
	currently_selected = -1
	
func _on_player_ready():
	for i in range(hotbar_slots.size()):
		if Global.player.attack_dict.has(i):
			hotbar_slots[i].icon.texture = Global.player.attack_dict[i].icon
	
