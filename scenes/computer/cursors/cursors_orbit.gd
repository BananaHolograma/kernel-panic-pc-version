class_name CursorsOrbit extends Node2D


@onready var cursors: Array[Cursor] = []


func display_cursor(idx: int):
	var cursors = get_children()
	
	if cursors[idx]:
		cursors[idx].show()
