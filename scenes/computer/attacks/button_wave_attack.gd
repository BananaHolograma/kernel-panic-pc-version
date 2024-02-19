class_name ButtonWaveAttack extends Attack

const BUTTON_HAZARD = preload("res://scenes/computer/attacks/elements/button_hazard.tscn")

@export var delay_between_spawn := 1.0
@export var amount := 10

func _ready():
	name = "ButtonWaveAttack"
	

func start():
	send_cursor_to_target()
	
	await focused_target
	
	for i in range(amount):
		var pos = random_limit_position(LIMITS.LEFT)
		var button = BUTTON_HAZARD.instantiate() as ButtonHazard
		
		button.position = pos
		terminal_limits.add_child(button)
		
		await get_tree().create_timer(delay_between_spawn).timeout

	
	
	
	

