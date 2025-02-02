extends Node

@onready var music: AudioStreamPlayer = $Music
@onready var sfx: AudioStreamPlayer = $SFX
@onready var ambient: AudioStreamPlayer = $Ambient
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var amazon_coupon_malware = $Interface/AmazonCouponMalware
@onready var post_processing_layer: CanvasLayer = $PostProcessingLayer
@onready var crt: ColorRect = $PostProcessingLayer/Control/CRT
@onready var danger_color: ColorRect = $PostProcessingLayer/Control/DangerColor
@onready var game_camera: GameCamera = %GameCamera
@onready var black_bars: BlackBars = $Cinematic/BlackBars


const COMPUTER_IDLE = preload("res://assets/sounds/computer_idle.ogg")
const PM_GC_DISTORTED_GLITCH_LFE_IMPACT_26 = preload("res://assets/sounds/PM_GC_DISTORTED_GLITCH_LFE_IMPACT_26.ogg")
const PM_GC_DISTORTED_GLITCH_LFE_IMPACT_18 = preload("res://assets/sounds/PM_GC_DISTORTED_GLITCH_LFE_IMPACT_18.ogg")


func _input(_event: InputEvent):
	if Input.is_action_just_pressed("ui_accept"):
			change_to_next_scene()

func change_to_next_scene():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/loading/loading_screen.tscn")
		
		
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	SceneTransitioner.next_scene_path = "res://scenes/computer/main.tscn"
	SceneTransitioner.no_background = true
	
	animation_player.animation_finished.connect(on_animation_finished)
	
	ambient.stream = COMPUTER_IDLE
	ambient.play()
	
	await get_tree().create_timer(1.5).timeout
	
	black_bars.enter()
	await black_bars.entered
	
	animation_player.play("exe_click")


func on_animation_finished(animation_name: String):
	if animation_name == "exe_click":
		black_bars.exit()
		sfx.stream = PM_GC_DISTORTED_GLITCH_LFE_IMPACT_26
		sfx.play()
		game_camera.shake_camera_component_2d.shake(20.0, 4.5)
		var tween = create_tween()
		tween.tween_property(crt.material, "shader_parameter/noiseIntensity", 0.015, sfx.stream.get_length() - 2).from_current()
		
		await tween.finished
		game_camera.shake_camera_component_2d.shake(30.0, 3)
		sfx.stream = PM_GC_DISTORTED_GLITCH_LFE_IMPACT_18
		sfx.play()
		
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(danger_color, "color", Color(1.0, 0.21, 0.07, 0.58) , sfx.stream.get_length() - 1).from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(game_camera, "zoom", Vector2(7, 7), sfx.stream.get_length())
		tween.tween_property(game_camera, "global_position", game_camera.position - Vector2(310, 180), sfx.stream.get_length()).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(crt.material, "shader_parameter/noiseIntensity", 0.05, sfx.stream.get_length()).from(0.015)
		tween.tween_property(crt.material, "shader_parameter/shake", 0.015, sfx.stream.get_length()).from_current()
		
		await tween.finished
		
		change_to_next_scene()
		
