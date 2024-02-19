class_name Run extends Ground


func _enter():
	if animated_sprite:
		animated_sprite.play("run")
	
	FSM.actor.velocity.y = 0


func _ready():
	motion_component.stopped.connect(on_stopped)


func physics_update(delta):
	super.physics_update(delta)
	
	if input_direction.is_zero_approx():
		motion_component.decelerate(true, delta)
	else:
		motion_component.accelerate(input_direction, delta)

	FSM.actor.move_and_slide()


func on_stopped():
	state_finished.emit("Idle", {})
