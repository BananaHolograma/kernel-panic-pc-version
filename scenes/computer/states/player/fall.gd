class_name Fall extends Air


func _enter():
	if animated_sprite:
		animated_sprite.play("fall")



func physics_update(delta):
	super.physics_update(delta)
	
	if not horizontal_direction.is_zero_approx():
		motion_component.accelerate_horizontally(horizontal_direction)


	if FSM.actor.is_on_floor():
		if horizontal_direction.is_zero_approx():
			state_finished.emit("Idle", {})
		else:
			state_finished.emit("Run", {})
	
	if Input.is_action_just_pressed("jump") and gravity_component.can_jump():
		state_finished.emit("Jump", {})
	
	FSM.actor.move_and_slide()
