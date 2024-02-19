class_name ButtonWaveAttack extends Attack


func _ready():
	name = "ButtonWaveAttack"


func start():
	send_cursor_to_target()
	
	await get_tree().create_timer(3.0).timeout
	remove_cursor_from_target()
	
	

