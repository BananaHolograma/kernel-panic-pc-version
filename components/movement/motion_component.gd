class_name MotionComponent extends Node

signal reached_max_speed
signal stopped
signal speed_temporary_finished

@export var actor: CharacterBody2D

@export_group("Speed")
@export var max_speed := 85.0
@export var acceleration := 10.0
@export var friction := 15.0
@export var default_speed_temporary_time := 2.0

var current_speed: float
var speed_temporary_timer: Timer

var facing_direction := Vector2.ZERO:
	set(value):
		facing_direction = value
		last_faced_direction = facing_direction
		
var last_faced_direction: Vector2:
	set(value):
		if not value.is_zero_approx():
			last_faced_direction = value
			
			
func _ready():
	_create_speed_temporary_timer()
	current_speed = max_speed


func accelerate(direction: Vector2, delta: float = get_physics_process_delta_time()) -> MotionComponent:
	facing_direction = _normalize_vector(direction)
	
	if not facing_direction.is_zero_approx():
		var previous_velocity = actor.velocity
		
		if acceleration > 0:
			actor.velocity = actor.velocity.move_toward(facing_direction * current_speed, acceleration * delta)
		else:
			actor.velocity = facing_direction * current_speed
			
		if previous_velocity.x != actor.velocity.x and abs(actor.velocity.x) >= current_speed:
			reached_max_speed.emit()
	
	return self


func decelerate(force_stop: bool = false, delta: float = get_physics_process_delta_time()) -> MotionComponent:	
	if force_stop or friction == 0:
		if not actor.velocity.is_zero_approx():
			actor.velocity = Vector2.ZERO
			stopped.emit()
	else:
		var previous_velocity = actor.velocity
		actor.velocity = actor.velocity.move_toward(Vector2.ZERO, friction * delta)
		
		if not previous_velocity.is_zero_approx() and actor.velocity.is_zero_approx():
			stopped.emit()
			
	return self


func accelerate_horizontally(direction: Vector2, delta: float = get_physics_process_delta_time()) -> MotionComponent:
	facing_direction = _normalize_vector(direction)
	
	if not facing_direction.is_zero_approx():
		if acceleration > 0:
			actor.velocity.x = move_toward(actor.velocity.x, facing_direction.x * current_speed, acceleration * delta)
		else:
			actor.velocity.x = facing_direction.x * current_speed

	return self


func decelerate_horizontally(force_stop: bool = false, delta: float = get_physics_process_delta_time()) -> MotionComponent:	
	if force_stop or friction == 0:
		if not actor.velocity.x == 0:
			actor.velocity.x = 0
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, friction * delta)
	
	return self


func change_speed_temporary(new_speed: float, time: float = default_speed_temporary_time):
	current_speed = new_speed
	
	_create_speed_temporary_timer(time)
	speed_temporary_timer.start()
	

func _create_speed_temporary_timer(time: float = default_speed_temporary_time):
	if is_instance_valid(speed_temporary_timer) and speed_temporary_timer.is_inside_tree():
		if speed_temporary_timer.wait_time !=  time:
			speed_temporary_timer.stop()
			speed_temporary_timer.wait_time = time
		return
		
	speed_temporary_timer = Timer.new()
	speed_temporary_timer.name = "SpeedTemporaryTimer"
	speed_temporary_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	speed_temporary_timer.autostart = false
	speed_temporary_timer.one_shot = true
	speed_temporary_timer.wait_time = time

	add_child(speed_temporary_timer)
	speed_temporary_timer.timeout.connect(on_speed_temporary_timeout)
	
	
func _normalize_vector(value: Vector2) -> Vector2:
	return value if value.is_normalized() else value.normalized()


func on_speed_temporary_timeout():
	current_speed = max_speed
