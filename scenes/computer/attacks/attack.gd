class_name Attack extends Node2D

@export var terminal: TextureRect
@export var active_cursor: Cursor
@export var target: Player


func _enter_tree():
	target = get_tree().get_first_node_in_group("player")
	
	
func with_terminal(_terminal: TextureRect) -> Attack:
	terminal = _terminal
	
	return self


func with_cursor(cursor: Cursor) -> Attack:
	active_cursor = cursor
	active_cursor.activated.emit()
	
	return self


func start():
	pass


func send_cursor_to_target():
	var cursor_copy = active_cursor.duplicate_sprite()
	cursor_copy.scale *= 1.4
	
	target.add_child(cursor_copy)
	var tween = create_tween()
	tween.tween_property(cursor_copy, "global_position", target.global_position, 1.5)\
		.from(active_cursor.global_position)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		
	await tween.finished
	cursor_copy.position = Vector2.ZERO
