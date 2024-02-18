class_name Idle extends Ground


func _enter():
	if animated_sprite:
		if not previous_states.is_empty() and previous_states.back() is Air:
			animated_sprite.animation_finished.connect(on_landed)
			animated_sprite.play("land")
		else:
			animated_sprite.play("idle")
	
	motion_component.decelerate(true)
	gravity_component.reset_jumps()


func _exit():
	if animated_sprite.animation_finished.is_connected(on_landed):
		animated_sprite.animation_finished.disconnect(on_landed)


func physics_update(delta):
	super.physics_update(delta)
	
	FSM.actor.move_and_slide()
	
	if not horizontal_direction.is_zero_approx() and FSM.actor.is_on_floor():
		state_finished.emit("Run", {})
		return
		
	if Input.is_action_just_pressed("jump") and gravity_component.can_jump():
		state_finished.emit("Jump", {})


func on_landed():
	animated_sprite.play("idle")
