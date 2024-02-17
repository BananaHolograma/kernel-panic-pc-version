extends Node

const FADE_OVERLAY = preload("res://ui/overlays/fade_overlay.tscn")

@export var minutes_to_resist := 5

@onready var game_camera: GameCamera = $GameCamera
@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var game_timer: Timer = $GameTimer


func _ready():
	_add_overlay()

	game_camera.global_position = get_viewport().get_visible_rect().size / 2


func on_fade_in_completed(overlay):
	game_timer.wait_time = 5 * 60
	game_timer.start()
	
	overlay.queue_free()


func _add_overlay():
	var fade_overlay = FADE_OVERLAY.instantiate()
	fade_overlay.auto_fade_in = true
	fade_overlay.fade_in_duration = 2.5
	add_child(fade_overlay)
	fade_overlay.on_complete_fade_in.connect(on_fade_in_completed.bind(fade_overlay))
	
