class_name LaserWheel extends Attack

@export var lasers := 1

@onready var available_lasers: Array[LaserWheelMarker] = []
@onready var remaining_lasers := lasers:
	set(value):
		remaining_lasers = value
		
		if remaining_lasers == 0:
			finished.emit()


func _ready():
	finished.connect(func(): queue_free())
	prepare_lasers()
	collect_lasers_and_shoot()
	

func collect_lasers_and_shoot():
	for i in range(lasers):
		var laser = available_lasers.pick_random()
		laser.finished.connect(func(): remaining_lasers -= 1)
		laser.shoot()


func prepare_lasers():
	var battleground_lasers = get_tree().get_nodes_in_group("laser_wheel")
	
	## This needs to be done manually to have the type Laser inside the arrayas the group returns Array[Node]
	for laser: LaserWheel in battleground_lasers:
		available_lasers.append(laser)
		
	available_lasers = available_lasers.filter(func(laser: LaserWheelMarker): return not laser.shooting)
