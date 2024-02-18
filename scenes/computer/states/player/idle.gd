class_name Idle extends Ground


func _enter():
	if animated_sprite:
		animated_sprite.play("idle")


func physics_update(delta):
	super.physics_update(delta)
	
	FSM.actor.move_and_slide()
	
	if not horizontal_direction.is_zero_approx() and FSM.actor.is_on_floor():
		state_finished.emit("Run", {})
