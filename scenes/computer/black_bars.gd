class_name BlackBars extends Control

signal entered
signal exited

@export var time_to_enter := 0.8
@export var time_to_exit := 0.8 

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar



func enter():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(top_bar, "position:y", top_bar.position.y + 50, time_to_enter).set_ease(Tween.EASE_IN)
	tween.tween_property(bottom_bar, "position:y", bottom_bar.position.y - 50, time_to_enter).set_ease(Tween.EASE_IN)
	
	await tween.finished
	entered.emit()


func exit():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(top_bar, "position:y", top_bar.position.y - 100, time_to_exit).set_ease(Tween.EASE_IN)
	tween.tween_property(bottom_bar, "position:y", bottom_bar.position.y + 100, time_to_exit).set_ease(Tween.EASE_IN)
	
	await tween.finished
	exited.emit()
