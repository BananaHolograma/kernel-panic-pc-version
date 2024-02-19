class_name ButtonWaveAttack extends Attack

const BUTTON_HAZARD = preload("res://scenes/computer/attacks/elements/button_hazard.tscn")

@export var delay_between_spawn := 1.0
@export var amount := 10

func _ready():
	name = "ButtonWaveAttack"
	

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
		terminal_limits.add_child(button)
		
		await get_tree().create_timer(delay_between_spawn).timeout

	
	
	
	

