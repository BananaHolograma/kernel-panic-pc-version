class_name Idle extends Ground


func _enter():
	if animated_sprite:
		animated_sprite.play("idle")

func physics_update(delta):
	super.physics_update(delta)
	
	FSM.actor.move_and_slide()
