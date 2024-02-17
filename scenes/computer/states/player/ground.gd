class_name Ground extends State

@export var animated_sprite: AnimatedSprite2D

var horizontal_direction: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO


func physics_update(delta):
	get_input_direction()
	
	#if not owner.is_on_floor():
		#platformer_movement.apply_gravity(delta)
		#
				
func get_input_direction():
	horizontal_direction = VectorWizard.translate_x_axis_to_vector(Input.get_axis("move_left", "move_right"))
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "ui_down").normalized() # Move down not used
