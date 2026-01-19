extends Control

func _ready() -> void:
	Minimaps.register_parent_viewport($SubViewportContainer/SubViewport)
