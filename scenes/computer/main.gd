extends Node

signal timer_ended

const FADE_OVERLAY = preload("res://ui/overlays/fade_overlay.tscn")

@export var minutes_to_resist := 10

@onready var game_camera: GameCamera = $GameCamera
@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var game_timer: Timer = $GameTimer

var seconds_passed := 0

func _ready():
	#GameEvents.lock_player.emit()
	game_camera.limit_smoothed = false
	game_camera.global_position = get_viewport().get_visible_rect().size / 2
	#_add_overlay()
	
	game_timer.timeout.connect(on_game_timer_second_passed)
	start_gameplay_timer() ## TODO - move after overlay is loaded


func start_gameplay_timer():
	progress_bar.value = 0
	progress_bar.max_value = minutes_to_resist * 60
	
	game_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	game_timer.wait_time = 1.0
	game_timer.one_shot = false
	game_timer.autostart = false
	game_timer.start()


func on_fade_in_completed(overlay):
	overlay.queue_free()
	game_camera.limit_smoothed = true
	#GameEvents.unlock_player.emit()


func on_game_timer_second_passed():
	seconds_passed += 1
	
	progress_bar.value = seconds_passed
	
	if seconds_passed >= minutes_to_resist * 60:
		game_timer.stop()
		timer_ended.emit()
	
	
func _add_overlay():
	var fade_overlay = FADE_OVERLAY.instantiate()
	fade_overlay.auto_fade_in = true
	fade_overlay.fade_in_duration = 3.5
	add_child(fade_overlay)
	fade_overlay.on_complete_fade_in.connect(on_fade_in_completed.bind(fade_overlay))
	

	
