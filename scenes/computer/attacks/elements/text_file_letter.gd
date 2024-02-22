class_name TextFileLetter extends Node2D


@export var angle := 0
@export var direction := Vector2.ZERO
@export var speed := randf_range(2.0, 3.5)

@onready var letter: Label = $Letter


func _ready():
	letter.text = Utilities.generate_random_string(1)
	direction = Vector2.RIGHT.rotated(deg_to_rad(angle))
	
	GameEvents.losed_game.connect(func(): queue_free())
	GameEvents.winned_game.connect(func(): queue_free())
	

func _process(_delta):
	if not direction.is_zero_approx():
		global_position += direction * speed


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
