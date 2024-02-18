class_name GravityComponent extends Node

signal enabled
signal disabled
signal suspended_gravity_temporary(time: float)
signal jumped(position: Vector2)
signal allowed_jumps_reached(positions: Array[Vector2])
signal finished_dash(position: Vector2)
signal dash_free_from_cooldown(position: Vector2, dash_queue: Array[Vector2])

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

@export_group("")
@export var dash_speed := 100.0
@export_range(1, 100, 1, "or_greater") var times_can_dash := 1
@export var disable_gravity_while_dashing := true
@export var decelerate_when_dash_ends := true
@export var reset_dash_when_on_floor := false
@export var can_dash_while_dashing := true
@export var dash_cooldown := 0:
	set(value):
		dash_cooldown = max(0.05, value)
		
@export var dash_duration: float:
	set(value):
		dash_duration = max(0.05, value)
		_create_dash_duration_timer(dash_duration)


var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

var suspend_gravity_timer: Timer
var dash_duration_timer: Timer
var dash_cooldown_timer: Timer

var dash_queue: Array[Vector2] = []
var jump_queue: Array[Vector2] = []

var is_dashing := false


func _ready():
	jump_velocity = _calculate_jump_velocity()
	jump_gravity = _calculate_jump_gravity()
	fall_gravity = _calculate_fall_gravity()
	
	_create_dash_duration_timer()
	suspended_gravity_temporary.connect(on_suspended_gravity_temporary)
	

func gravity() -> float:
	if actor.up_direction.is_equal_approx(Vector2.DOWN):
		return jump_gravity if actor.velocity.y > 0 else fall_gravity
	
	return jump_gravity if actor.velocity.y < 0 else fall_gravity 
		

func apply_gravity(delta: float = get_physics_process_delta_time()) -> GravityComponent:
	if active:
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
		

func is_falling():
	var inverted_gravity = actor.up_direction.is_equal_approx(Vector2.DOWN)
	
	return active \
		and not actor.is_on_floor() \
		and (actor.velocity.y < 0 if inverted_gravity else actor.velocity.y > 0)
	
	
func enable():
	active = true
	

func disable():
	active = false
	
	
func can_jump() -> bool:
	var available_jumps = jump_queue.size() < allowed_jumps
	
	return available_jumps


func jump(height: float = jump_height, bypass: bool = false):
	if bypass or can_jump():
		var height_reduced = max(0, jump_queue.size()) * height_reduced_by_jump
	
		actor.velocity.y = _calculate_jump_velocity(height - height_reduced, jump_time_to_peak)
		_add_position_to_jump_queue(actor.global_position)
		
		jumped.emit()


func reset_jumps(amount: int = jump_queue.size()):
	if amount >= jump_queue.size():
		jump_queue.clear()
	else:
		jump_queue = jump_queue.slice(clamp(amount, 0, jump_queue.size()))
	

func can_dash(direction: Vector2) -> bool:
	direction = _normalize_vector(direction)
	
	var available_dashes = dash_queue.size() < times_can_dash and not direction.is_zero_approx()
	var while_dashing = can_dash_while_dashing or (not can_dash_while_dashing and not is_dashing)
	
	
	return available_dashes & while_dashing
		

func dash(direction: Vector2) -> GravityComponent:
	if can_dash(direction):
		direction = _normalize_vector(direction)
		is_dashing = true
		actor.velocity = direction * dash_speed
		dash_queue.append(actor.global_position)
		
		if dash_duration_timer and dash_duration_timer.wait_time > 0:
			dash_duration_timer.timeout.emit()
		
		dash_duration_timer.start()
		

	return self


func _add_position_to_jump_queue(_position: Vector2):
	jump_queue.append(_position)
	
	if jump_queue.size() == allowed_jumps:
		allowed_jumps_reached.emit(jump_queue)
	
	
func _calculate_jump_velocity(_jump_height: float = jump_height, time_to_peak: float = jump_time_to_peak):
	return 2.0 * _jump_height / (time_to_peak * actor.up_direction.y)


func _calculate_jump_gravity(_jump_height: float = jump_height, time_to_peak: float = jump_time_to_peak):
	return override_jump_gravity if override_jump_gravity > 0 else 2.0 * _jump_height / (pow(time_to_peak, 2))
	
	
func _calculate_fall_gravity(_jump_height: float = jump_height, time_to_fall: float = jump_time_to_fall):
	return override_fall_gravity if override_fall_gravity > 0 else 2.0 * _jump_height / (pow(time_to_fall, 2))


func _normalize_vector(value: Vector2) -> Vector2:
	return value if value.is_normalized() else value.normalized()

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
	suspend_gravity_timer.timeout.connect(on_suspended_gravity_timeout)


func _create_dash_duration_timer(time: float = dash_duration):
	if is_instance_valid(dash_duration_timer) and dash_duration_timer.is_inside_tree():
		if dash_duration_timer.wait_time !=  time:
			dash_duration_timer.stop()
			dash_duration_timer.wait_time = time
		return
		
	dash_duration_timer = Timer.new()
	dash_duration_timer.name = "DashDurationTimer"
	dash_duration_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_duration_timer.autostart = false
	dash_duration_timer.one_shot = true
	dash_duration_timer.wait_time = time
	
	add_child(dash_duration_timer)
	dash_duration_timer.timeout.connect(on_dash_duration_timeout)


func _create_dash_cooldown_timer(time: float = dash_duration):
	if is_instance_valid(dash_cooldown_timer) and dash_cooldown_timer.is_inside_tree():
		if dash_cooldown_timer.wait_time !=  time:
			dash_cooldown_timer.stop()
			dash_cooldown_timer.wait_time = time
		return
		
	dash_cooldown_timer = Timer.new()
	dash_cooldown_timer.name = "DashCooldownTimer"
	dash_cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_cooldown_timer.autostart = true
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.wait_time = time
	
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.timeout.connect(on_dash_cooldown_timeout)



func on_suspended_gravity_temporary(_time: float):
	disable()
	
	
func on_suspended_gravity_timeout():
	enable()


func on_dash_duration_timeout():
	is_dashing = false
	
	if dash_cooldown > 0:
		_create_dash_cooldown_timer(dash_cooldown)
		
	var last_dash: Vector2 = dash_queue.back() if dash_queue.size() > 0 else Vector2.ZERO
	
	finished_dash.emit(last_dash)
	

func on_dash_cooldown_timeout():
	if dash_queue.is_empty():
		return

	dash_free_from_cooldown.emit(dash_queue.pop_back(), dash_queue)
