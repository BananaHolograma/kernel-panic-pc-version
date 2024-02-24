extends Panel

@onready var timer: Timer = $Timer
@onready var time_label: Label = $Time/Label

var seconds_passed := 0

func _ready():
	GameEvents.game_started.connect(on_game_started)
	time_label.text = "12:30 PM"

func on_game_started():
	timer.start()


func _on_timer_timeout():
	seconds_passed += 1
	var minutes_passed = round(seconds_passed / 60.0)
	time_label.text = "12:%s PM" %  "3%s" % minutes_passed if seconds_passed <= 600 else "40"
