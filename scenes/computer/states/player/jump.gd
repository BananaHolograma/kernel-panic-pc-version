class_name Jump extends Air


func _enter():
	if animated_sprite:
		animated_sprite.play("jump")
	
	gravity_component.jump()


func physics_update(delta):
	super.physics_update(delta)
	
	if not horizontal_direction.is_zero_approx():
		motion_component.accelerate_horizontally(horizontal_direction)

	FSM.actor.move_and_slide()
	
	if gravity_component.is_falling():
		state_finished.emit("Fall", {})
