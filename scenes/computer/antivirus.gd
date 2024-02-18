class_name Antivirus extends CharacterBody2D

@onready var cursors: CursorsOrbit = $Cursors
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx: AudioStreamPlayer = $SFX

const SERAPHIM_VOICE_6 = preload("res://assets/sounds/Seraphim_Voice6.wav")
const HOLY_APPEAR = preload("res://assets/sounds/holy_appear.ogg")

func _ready():
	animation_player.animation_finished.connect(on_animation_finished)
	animation_player.play("appear")
	

func _display_cursors(delay_between: float = 1.0):
	for cursor_idx in range(cursors.get_child_count()):
		cursors.display_cursor(cursor_idx)
		await get_tree().create_timer(delay_between).timeout


func _holy_appear():
	## TEMPORARY
	var sfx2 = AudioStreamPlayer.new()
	sfx2.stream = HOLY_APPEAR
	add_child(sfx2)

	sfx2.finished.connect(
		func(): 
		sfx2.queue_free()
		sfx.stream = SERAPHIM_VOICE_6
		sfx.volume_db = linear_to_db(0.8)
		sfx.play()
	)
	sfx2.play()


func on_animation_finished(animation_name: String):
	if animation_name == 'appear':
		animation_player.play("idle")
		_display_cursors()
