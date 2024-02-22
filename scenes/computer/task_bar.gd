extends Panel

@onready var timer: Timer = $Timer
@onready var time_label: Label = $Time/Label

var seconds_passed := 0

func _ready():
	GameEvents.game_started.connect(on_game_started)


func on_game_started():
	timer.start()


func _on_timer_timeout():
	seconds_passed += 1
	var displayed_minutes = round(seconds_passed / 60)
	time_label.text = "12:%s PM" %  "3%s" % displayed_minutes if seconds_passed <= 600 else "40"
