class_name Run extends Ground


func _enter():
	if animated_sprite:
		animated_sprite.play("run")
	
	FSM.actor.velocity.y = 0
	gravity_component.reset_jumps()


func _ready():
	motion_component.stopped.connect(on_stopped)


func physics_update(delta):
	super.physics_update(delta)
	
	if horizontal_direction.is_zero_approx():
		motion_component.decelerate(true, delta)
	else:
		motion_component.accelerate(horizontal_direction, delta)
		
	if Input.is_action_just_pressed("jump") and gravity_component.can_jump():
		state_finished.emit("Jump", {})

	FSM.actor.move_and_slide()


func on_stopped():
	state_finished.emit("Idle", {})
