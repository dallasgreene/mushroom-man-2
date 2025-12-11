class_name HotbarSlot extends Control


var unfocused_slot: Texture2D = preload("uid://myt3d7u8pgve")
var focused_slot: Texture2D = preload("uid://go0say7nc85")
var background: Sprite2D
var selected_border: Sprite2D
var slot_id: int
@onready var icon: Sprite2D = %Icon
## a key value of the attack_dict in player
var attack_index: int = -1

var is_focused: bool = false
var is_selected: bool = false
var is_ongoing: bool = false


func _ready() -> void:
	background = $background
	selected_border = $selected_border


func update_texture() -> void:
	if is_selected:
		selected_border.show()
	else:
		selected_border.hide()
	#elif is_ongoing:
		#background.texture = ongoing_slot
	if is_focused:
		background.texture = focused_slot
	else:
		background.texture = unfocused_slot


func hover() -> void:
	is_focused = true
	update_texture()


func unhover() -> void:
	is_focused = false
	update_texture()


func select() -> void:
	is_selected = true
	update_texture()
	SignalBus.player_selected_attack.emit(attack_index)


func unselect() -> void:
	is_selected = false
	update_texture()
	SignalBus.player_unselected_attack.emit()


func set_ongoing() -> void:
	is_ongoing = true
	update_texture()


func unset_ongoing() -> void:
	is_ongoing = false
	update_texture()
