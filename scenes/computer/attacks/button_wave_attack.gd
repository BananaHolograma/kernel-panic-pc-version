class_name ButtonWaveAttack extends Attack

const BUTTON_HAZARD = preload("res://scenes/computer/attacks/elements/button_hazard.tscn")
const ARROW = preload("res://assets/arrows/Arrow.png")

@export var delay_between_spawn := 1.0
@export var amount := 10

func _ready():
	name = "ButtonWaveAttack"
	
	finished.connect(on_finished)



func start():
	if duplicated_cursor == null:
		send_cursor_to_target()
	
		await focused_target
	
	for i in range(amount):
		var spawn = random_limit_position()
		var button = BUTTON_HAZARD.instantiate() as ButtonHazard
		
		match spawn.limit:
			LIMITS.LEFT:
				button.direction = Vector2.RIGHT
			LIMITS.RIGHT:
				button.direction = Vector2.LEFT	
			LIMITS.TOP:
				button.direction = Vector2.DOWN
			LIMITS.BOTTOM:
				button.direction = Vector2.UP
			
		button.position = spawn.position
		var arrow = Sprite2D.new()
		_visual_feedback(arrow, spawn.position)
		
		await get_tree().create_timer(delay_between_spawn).timeout
		
		terminal_limits.add_child(button)
		arrow.queue_free()
		
	finished.emit()


func _visual_feedback(arrow: Sprite2D, spawn_position: Vector2):
	arrow.texture = ARROW
	arrow.position = spawn_position
	terminal_limits.add_child(arrow)
	arrow.look_at(spawn_position.normalized())
	

func on_finished():
	remove_cursor_from_target()	
	queue_free()
