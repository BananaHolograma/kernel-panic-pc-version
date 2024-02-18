class_name MotionComponent extends Node

signal reached_max_speed
signal stopped

@export var actor: CharacterBody2D

@export_group("Speed")
@export var max_speed := 85.0
@export var acceleration := 10.0
@export var friction := 15.0

var current_speed: float

var facing_direction := Vector2.ZERO:
	set(value):
		facing_direction = value
		last_faced_direction = facing_direction
		
var last_faced_direction: Vector2:
	set(value):
		if not value.is_zero_approx():
			last_faced_direction = value
			
			
func _ready():
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


func _normalize_vector(value: Vector2) -> Vector2:
	return value if value.is_normalized() else value.normalized()
