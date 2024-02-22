extends Control

@onready var player: Player = $MovementPlayground/Player


func _ready():
	hide()


func _on_back_arrow_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hide()
