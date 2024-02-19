class_name Attack extends Node2D

signal focused_target

enum LIMITS {
	TOP,
	BOTTOM,
	RIGHT,
	LEFT
}

@export var terminal_limits: ColorRect
@export var active_cursor: Cursor
@export var target: Player

var duplicated_cursor: Sprite2D
var original_scale: Vector2
var new_scale_multiplier := 1.5

var limits := {}

func _enter_tree():
	target = get_tree().get_first_node_in_group("player")
	
	
func with_terminal(_terminal_limits: ColorRect) -> Attack:
	terminal_limits = _terminal_limits
	
	var min_left =  terminal_limits.position.x
	var min_top =  terminal_limits.position.y
	var min_right =  terminal_limits.position.x + terminal_limits.size.x
	var min_bottom =  terminal_limits.position.y + terminal_limits.size.y
	
	limits = {
		"min_left":  min_left,
		"min_top":  min_top,
		"min_right":  min_right,
		"min_bottom":  min_bottom,
		"max_left":  min_right,  # Set max to the opposite wall for valid range
		"max_top":  min_bottom,  # Set max to the opposite wall for valid range
		"max_right":  min_left, # Set max to the opposite wall for valid range
		"max_bottom":  min_top # Set max to the opposite wall for valid range
	}

	return self


func with_cursor(cursor: Cursor) -> Attack:
	active_cursor = cursor
	active_cursor.activated.emit()
	
	return self


func start():
	pass

func random_limit_position(limit: LIMITS) -> Vector2:
	match limit:
		LIMITS.LEFT:
			return Vector2(0, randi_range(0, terminal_limits.size.y))

	return Vector2.ZERO


func send_cursor_to_target():
	duplicated_cursor = active_cursor.duplicate_sprite()
	original_scale = duplicated_cursor.scale
	duplicated_cursor.scale *= new_scale_multiplier
	
	target.add_child(duplicated_cursor)
	var tween = create_tween()
	tween.tween_property(duplicated_cursor, "global_position", target.global_position, 1.5)\
		.from(active_cursor.global_position)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		
	await tween.finished
	focused_target.emit()
	duplicated_cursor.position = Vector2.ZERO
	

func remove_cursor_from_target():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(duplicated_cursor, "global_position", active_cursor.global_position, 1.5)\
		.from(target.global_position)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(duplicated_cursor, "scale", original_scale, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	await tween.finished
	duplicated_cursor.queue_free()
	active_cursor.returned.emit()
	
