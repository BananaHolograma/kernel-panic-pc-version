class_name Ground extends State

@export var animated_sprite: AnimatedSprite2D
@export var motion_component: MotionComponent

var horizontal_direction: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO


func physics_update(delta):
	get_input_direction()
		
				
func get_input_direction():
	horizontal_direction = VectorWizard.translate_x_axis_to_vector(Input.get_axis("move_left", "move_right"))
	input_direction = Input.get_vector("move_left", "move_right", "forward", "backward").normalized() # Move down not used
