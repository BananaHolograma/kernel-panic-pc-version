extends Node

@onready var music: AudioStreamPlayer = $Music
@onready var sfx: AudioStreamPlayer = $SFX
@onready var ambient: AudioStreamPlayer = $Ambient
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var amazon_coupon_malware = $Interface/AmazonCouponMalware
@onready var post_processing_layer: CanvasLayer = $PostProcessingLayer
@onready var crt: ColorRect = $PostProcessingLayer/Control/CRT
@onready var camera_2d: Camera2D = %Camera2D


const COMPUTER_IDLE = preload("res://assets/sounds/computer_idle.ogg")
const PM_GC_DISTORTED_GLITCH_LFE_IMPACT_26 = preload("res://assets/sounds/PM_GC_DISTORTED_GLITCH_LFE_IMPACT_26.ogg")
const PM_GC_DISTORTED_GLITCH_LFE_IMPACT_18 = preload("res://assets/sounds/PM_GC_DISTORTED_GLITCH_LFE_IMPACT_18.ogg")


func _ready():
	camera_2d.global_position = get_viewport().get_visible_rect().size / 2
	var tween = create_tween()
	tween.tween_property(camera_2d, "zoom", Vector2(1.05, 1.05), 1.0)
	
	animation_player.animation_finished.connect(on_animation_finished)
	
	ambient.stream = COMPUTER_IDLE
	ambient.play()
	
	await get_tree().create_timer(1.5).timeout
	
	animation_player.play("exe_click")
	
	
func on_animation_finished(animation_name: String):
	if animation_name == "exe_click":
		sfx.stream = PM_GC_DISTORTED_GLITCH_LFE_IMPACT_26
		sfx.play()
		
		var tween = create_tween()
		tween.tween_property(crt.material, "shader_parameter/noiseIntensity", 0.015, sfx.stream.get_length() - 2).from_current()
		
		await tween.finished
		
		sfx.stream = PM_GC_DISTORTED_GLITCH_LFE_IMPACT_18
		sfx.play()
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(camera_2d, "zoom", Vector2(10, 10), sfx.stream.get_length())
		tween.tween_property(camera_2d, "position", camera_2d.position - Vector2(100, 100), sfx.stream.get_length()).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(crt.material, "shader_parameter/noiseIntensity", 0.05, sfx.stream.get_length()).from(0.015)
		tween.tween_property(crt.material, "shader_parameter/shake", 0.015, sfx.stream.get_length()).from_current()
