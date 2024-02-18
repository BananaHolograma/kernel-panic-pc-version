class_name GravityComponent extends Node

signal enabled
signal disabled
signal suspended_gravity_temporary(time: float)

@export var actor: CharacterBody2D

@export_group("Gravity")
@export var active := true:
	set(value):
		if active != value:
			if value:
				enabled.emit()
				
			else:
				disabled.emit()
					
		active = value
		
@export var maximum_fall_velocity := 200.0
@export var override_jump_gravity := 0.0
@export var override_fall_gravity := 0.0

@export_group("Jump")
@export var allowed_jumps := 1
@export var height_reduced_by_jump := 0
@export var jump_height: float:
	set(value):
		jump_height = value
		if is_node_ready():
			jump_velocity = _calculate_jump_velocity(jump_height)
		
@export var jump_time_to_peak: float:
	set(value):
		jump_time_to_peak = value
		if is_node_ready():
			jump_gravity = _calculate_jump_gravity(jump_height, jump_time_to_peak)
		
@export var jump_time_to_fall: float:
	set(value):
		jump_time_to_fall = value
		if is_node_ready():
			fall_gravity = _calculate_fall_gravity(jump_height, jump_time_to_fall)
		
@export var coyote_jump_enabled := true
@export var coyote_jump_time_window := 0.1

var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

var suspend_gravity_timer: Timer

func _ready():
	jump_velocity = _calculate_jump_velocity()
	jump_gravity = _calculate_jump_gravity()
	fall_gravity = _calculate_fall_gravity()


func gravity() -> float:
	if actor.up_direction.is_equal_approx(Vector2.DOWN):
		return jump_gravity if actor.velocity.y > 0 else fall_gravity
	
	return jump_gravity if actor.velocity.y < 0 else fall_gravity 
		

func apply_gravity(delta: float = get_physics_process_delta_time()) -> GravityComponent:
	if enabled:
		var inverted_gravity = actor.up_direction.is_equal_approx(Vector2.DOWN)
		var gravity_force = gravity() * delta
		
		if inverted_gravity:
			gravity_force *= -1
		
		actor.velocity.y += gravity_force
		
		if maximum_fall_velocity > 0:
			if inverted_gravity:
				actor.velocity.y = max(actor.velocity.y, -maximum_fall_velocity)
			else:
				actor.velocity.y = min(actor.velocity.y, abs(maximum_fall_velocity))
			
	
	return self


func suspend_gravity_temporary(time: float):
	_create_suspend_gravity_duration_timer(time)
	suspend_gravity_timer.start()
	suspended_gravity_temporary.emit(suspend_gravity_timer.wait_time)
		

func enable():
	active = true
	

func disable():
	active = false
	

func _calculate_jump_velocity(_jump_height: float = jump_height, time_to_peak: float = jump_time_to_peak):
	return 2.0 * _jump_height / (time_to_peak * actor.up_direction.y)


func _calculate_jump_gravity(_jump_height: float = jump_height, time_to_peak: float = jump_time_to_peak):
	return override_jump_gravity if override_jump_gravity > 0 else 2.0 * _jump_height / (pow(time_to_peak, 2))
	
	
func _calculate_fall_gravity(_jump_height: float = jump_height, time_to_fall: float = jump_time_to_fall):
	return override_fall_gravity if override_fall_gravity > 0 else 2.0 * _jump_height / (pow(time_to_fall, 2))


func _create_suspend_gravity_duration_timer(time: float):
	if is_instance_valid(suspend_gravity_timer) and suspend_gravity_timer.is_inside_tree():
		if suspend_gravity_timer.wait_time !=  time:
			suspend_gravity_timer.stop()
			suspend_gravity_timer.wait_time = time
		return
		
	suspend_gravity_timer = Timer.new()
	suspend_gravity_timer.name = "SuspendGravityTimer"
	suspend_gravity_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	suspend_gravity_timer.autostart = false
	suspend_gravity_timer.one_shot = true
	suspend_gravity_timer.wait_time = time
	
	add_child(suspend_gravity_timer)
	suspend_gravity_timer.timeout.connect(on_suspend_gravity_timeout)


func on_suspend_gravity_timeout():
	active = true
