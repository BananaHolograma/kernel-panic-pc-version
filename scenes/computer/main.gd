extends Node

signal timer_ended
signal attack_routine_started
signal attack_routine_finished
signal winned_game
signal losed_game

const FADE_OVERLAY = preload("res://ui/overlays/fade_overlay.tscn")
const KERNEL = preload("res://scenes/world/kernel.tscn")

@onready var back_menu_dialog: ConfirmationDialog = %BackMenuDialog
@onready var options_menu: Control = %OptionsMenu

@onready var retry_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton


@onready var phase_calm_music: AudioStreamPlayer = $PhaseCalmMusic
@onready var phase_alert_music: AudioStreamPlayer = $PhaseAlertMusic
@onready var phase_danger_music: AudioStreamPlayer = $PhaseDangerMusic
@onready var phase_extreme_music: AudioStreamPlayer = $PhaseExtremeMusic
@onready var system_recovered_player: AudioStreamPlayer = $SystemRecoveredPlayer

@export var minutes_to_resist := 10

@onready var game_camera: GameCamera = $GameCamera
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var game_timer: Timer = $GameTimer
@onready var antivirus: Antivirus = $Antivirus
@onready var terminal: MSDosTerminal = $Control/Terminal
@onready var player: Player = $Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var kernel_spawn: Marker2D = %KernelSpawn


enum GAME_STATE {
	RUNNING,
	WIN,
	LOSE
}

var seconds_passed := 0
var current_game_state := GAME_STATE.RUNNING:
	set(value):
		current_game_state = value
		
		match current_game_state:
			GAME_STATE.WIN:
				winned_game.emit()
			GAME_STATE.LOSE:
				losed_game.emit()


func _input(event):
	if Input.is_action_just_pressed("ui_cancel") and not options_menu.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		back_menu_dialog.popup_centered()

		get_tree().paused = true	
	

func _ready():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	phase_calm_music.volume_db = linear_to_db(0.0001) # -80 db
	phase_alert_music.volume_db = linear_to_db(0.0001) # -80 db
	phase_danger_music.volume_db = linear_to_db(0.0001) # -80 db
	phase_extreme_music.volume_db = linear_to_db(0.0001) # -80 db
	
	
	winned_game.connect(on_winned_game)
	losed_game.connect(on_losed_game)
	player.before_dead.connect(func():
		phase_calm_music.stop()
		phase_alert_music.stop()
		phase_danger_music.stop()
		phase_extreme_music.stop()
	)
	player.died.connect(on_player_dead)
	
	timer_ended.connect(on_timer_ended)
	animation_player.animation_finished.connect(on_animation_finished)
	
	GameEvents.lock_player.emit()
	
	game_camera.limit_smoothed = false
	game_camera.global_position = get_viewport().get_visible_rect().size / 2
	_add_overlay()
	
	game_timer.timeout.connect(on_game_timer_second_passed)
	antivirus.terminal = terminal
	antivirus.phase_changed.connect(on_antivirus_phase_changed)
	antivirus.prepared.connect(func(): 
		animation_player.play("calm_music_start")
		game_timer.start()
		GameEvents.game_started.emit()
	)
	start_gameplay_timer()
	player.appear()
	
	GameEvents.show_pause_menu.connect(func():
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	)
	
	GameEvents.hidden_pause_menu.connect(func():
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)
	
	winned_game.emit()
	

func start_gameplay_timer():
	progress_bar.value = 0
	progress_bar.max_value = minutes_to_resist * 60
	
	game_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	game_timer.wait_time = 1.0
	game_timer.one_shot = false
	game_timer.autostart = false


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
	

func _back_to_menu() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/world/menu_screen.tscn")


func on_antivirus_phase_changed(_previous: Antivirus.PHASES, current: Antivirus.PHASES):
	match(current):
		Antivirus.PHASES.ALERT:
			phase_alert_music.play()
			animation_player.play("calm_to_alert")
		Antivirus.PHASES.DANGER:
			phase_danger_music.play()
			animation_player.play("alert_to_danger")
		Antivirus.PHASES.EXTREME:
			phase_extreme_music.play()
			animation_player.play("danger_to_extreme")		


func on_animation_finished(animation_name: String):
	match animation_name:
		"calm_to_alert":
			phase_calm_music.stop()
		"alert_to_danger":
			phase_alert_music.stop()
		"danger_to_extreme":
			phase_danger_music.stop()


func on_player_dead():
	current_game_state = GAME_STATE.LOSE
	

func on_timer_ended():
	current_game_state = GAME_STATE.WIN
	
	
func on_winned_game():
	GameEvents.winned_game.emit()
	
	var kernel = KERNEL.instantiate()
	kernel_spawn.add_child(kernel)
	kernel.player_touched_kernel.connect(func():
		GameEvents.lock_player.emit()
		game_camera.shake_camera_component_2d.shake(20.0, 4.5)
	)
	

func on_losed_game():
	GameEvents.losed_game.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	animation_player.play("system_recovered")
	system_recovered_player.play()


func _on_back_menu_dialog_confirmed():
	get_tree().paused = true
	_back_to_menu()


func _on_back_menu_dialog_canceled():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _on_retry_button_pressed():
	get_tree().call_deferred("reload_current_scene")
	

func _on_quit_button_pressed():
	_back_to_menu()
