extends Node2D


@export var direction: Vector2
@export var min_speed := 2.5
@export var max_speed := 4.5

@onready var speed := randf_range(min_speed, max_speed)


func _process(_delta):
	global_position += direction * speed


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
