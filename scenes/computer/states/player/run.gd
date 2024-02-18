class_name Run extends Ground


func _enter():
	if animated_sprite:
		animated_sprite.play("run")


func physics_update(delta):
	super.physics_update(delta)
	
	if horizontal_direction.is_zero_approx():
		if FSM.actor.velocity.is_zero_approx():
			state_finished.emit("Idle", {})
			return
		else:
			motion_component.decelerate(delta)
	else:
		motion_component.accelerate(horizontal_direction, delta)

	FSM.actor.move_and_slide()
