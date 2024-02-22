extends Control

@onready var returning_time_label: Label = $ReturningTimeLabel

@export var time_to_return := 10

var seconds_passed := 0

func _input(event):
	if Input.is_action_just_pressed("blue_screen_shortcut") or Input.is_action_just_pressed("ui_accept"):
		_back_to_menu()


func _ready():
	returning_time_label.text = "Returning to the menu in %s ..." % time_to_return


func _on_timer_timeout():
	seconds_passed += 1
	
	returning_time_label.text = "Returning to the menu in %s ..." % str(time_to_return - seconds_passed)
	
	if seconds_passed >= time_to_return:
		_back_to_menu()


func _back_to_menu():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/world/menu_screen.tscn")
