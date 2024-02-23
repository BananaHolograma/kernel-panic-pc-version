class_name Kernel extends Node2D

signal player_touched_kernel

const BLUE_SCREEN = preload("res://scenes/world/blue_screen.tscn")


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var touch_sfx: AudioStreamPlayer = $TouchSFX
@onready var loop: AudioStreamPlayer = $Loop
@onready var implosion_particles: GPUParticles2D = $ImplosionParticles


func _ready():
	animation_player.play("idle")
	
	touch_sfx.finished.connect(func():
		get_tree().call_deferred("change_scene_to_packed", BLUE_SCREEN)
	)


func _on_area_2d_body_entered(body):
	if body is Player:
		loop.stop()
		player_touched_kernel.emit()


func _on_player_touched_kernel():
	touch_sfx.play()


func _on_detection_area_body_entered(body):
	if body is Player:
		implosion_particles.emitting = false
		Utilities.frame_freeze(0.1, 3.0)
