extends Node

signal timer_ended
signal attack_routine_started
signal attack_routine_finished

const FADE_OVERLAY = preload("res://ui/overlays/fade_overlay.tscn")

@export var minutes_to_resist := 10

@onready var game_camera: GameCamera = $GameCamera
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var game_timer: Timer = $GameTimer
@onready var antivirus: Antivirus = $Antivirus


var seconds_passed := 0

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	GameEvents.lock_player.emit()
	game_camera.limit_smoothed = false
	game_camera.global_position = get_viewport().get_visible_rect().size / 2
	_add_overlay()
	
	game_timer.timeout.connect(on_game_timer_second_passed)
	start_gameplay_timer() ## TODO - move after all animations are loaded
	

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
	

func on_game_timer_second_passed():
	seconds_passed += 1
	
	progress_bar.value = seconds_passed
	
	antivirus.phase_transition(progress_bar.value / progress_bar.max_value)
	
	if 	seconds_passed >= minutes_to_resist * 60:
		game_timer.stop()
		timer_ended.emit()
	
	
func _add_overlay():
	var fade_overlay = FADE_OVERLAY.instantiate()
	fade_overlay.auto_fade_in = true
	fade_overlay.fade_in_duration = 1.5
	add_child(fade_overlay)
	fade_overlay.on_complete_fade_in.connect(on_fade_in_completed.bind(fade_overlay))
	


#
#func on_attack_routine_finished():
	#start_attack_routine()
