class_name CursorsOrbit extends Node2D


@onready var arrow_cursor: Cursor = $ArrowCursor
@onready var hand_cursor: Cursor = $HandCursor
@onready var target_cursor: Cursor = $TargetCursor


func display_cursor(idx: int):
	var _cursors = get_children()
	
	if _cursors[idx]:
		_cursors[idx].show()


func arrow():
	return arrow_cursor
	
	
func hand():
	return hand_cursor
	

func target():
	return target_cursor
