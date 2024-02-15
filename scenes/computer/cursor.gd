class_name MouseCursor extends Node2D

const WIN_95_DEF = preload("res://assets/cursors/Win95/Win95Def.png")
const WIN_95_DEF_LOAD = preload("res://assets/cursors/Win95/Win95DefLoad.png")

@export var click_sound: AudioStream

@onready var icon: Sprite2D = $Icon
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func load_click(time: float = 1.5):
	audio_stream_player.stream = click_sound
	audio_stream_player.play()
	
	icon.texture = WIN_95_DEF_LOAD
	await get_tree().create_timer(max(0.05, time)).timeout
	
	icon.texture = WIN_95_DEF
	
