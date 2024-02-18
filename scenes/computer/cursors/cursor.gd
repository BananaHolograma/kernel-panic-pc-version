class_name Cursor extends Node2D

## The node that will be used as center reference for this cursor to orbit
@export var rotation_reference: Node2D
## The texture of the cursor
@export var texture: CompressedTexture2D
## The scale of the cursor
@export var texture_scale: Vector2 = Vector2(0.391, 0.422)
## The distance between the rotation reference center and the cursor starting from the center
@export var radius := 40
## This value always cannot be zero as the rotation needs at least a floating point value to start
@export var angle := PI / 4 
## The angular velocity which is used to rotate around the orbit.
@export var angular_velocity = PI / 2


func _ready():
	if texture:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.scale = texture_scale
		add_child(sprite)


func _process(delta):
	if is_node_ready() and texture:
		orbit(delta)


func orbit(delta: float = get_process_delta_time()):
	angle += delta * angular_velocity
	angle = fmod(angle, 2 * PI) ## This keeps the value range between 0 and 360 degrees
	
	var offset = Vector2(cos(angle), sin(angle)) * radius
	
	position = rotation_reference.position + offset
