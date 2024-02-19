class_name RailShooting extends Attack

const SHOOTING_CURSOR = preload("res://scenes/computer/attacks/elements/shooting_cursor.tscn")
const BULLET = preload("res://scenes/computer/attacks/elements/bullet.tscn")

@export var bullets_per_shoot := 2
@export var between_bullets_delay := 10.0 / 60.0
@export var shoot_delay := 1.5
@export var time_shooting := 10.0

var shooting_cursor

func _ready():
	name = "RailShooting"
	
	_create_timers()


func start():
	shooting_cursor = SHOOTING_CURSOR.instantiate()
	target.add_child(shooting_cursor)

	
func shoot():
	var origin = shooting_cursor.get_node("BulletOrigin")
	
	for i in range(bullets_per_shoot):
		var bullet = BULLET.instantiate()
		bullet.global_position = origin.global_position
		bullet.direction = shooting_cursor.global_position.direction_to(get_tree().get_first_node_in_group("player").global_position)
		
		get_tree().root.add_child(bullet)
		await get_tree().create_timer(between_bullets_delay).timeout
	


func _create_timers():
	var timer = Timer.new()
	timer.name = "ShootDelayTimer"
	timer.wait_time = shoot_delay
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(on_shoot_timeout)
	
	timer = Timer.new()
	timer.name = "TimeShootingTimer"
	timer.wait_time = time_shooting
	timer.autostart = true
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_time_shooting_timeout)


func on_shoot_timeout():
	shoot()


func on_time_shooting_timeout():
	finished.emit()


func on_finished():
	remove_cursor_from_target()
	queue_free()