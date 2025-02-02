class_name Cursor extends Node2D

signal activated
signal returned

## The node name for this cursor
@export var cursor_name: String
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

var sprite: Sprite2D
var in_battle := false

var target: Node
var following_target := false

var duplicated_cursor: Sprite2D
var original_scale: Vector2
var new_scale_multiplier := 1.5


func _ready():
	if texture:
		sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.scale = texture_scale
		add_child(sprite)
		
		activated.connect(on_activated)
		returned.connect(on_returned)


func _process(delta):
	if is_node_ready() and texture:
		orbit(delta)
		
		if following_target and target:
			duplicated_cursor.global_position += 20 * (duplicated_cursor.global_position.direction_to(target.global_position))
		
	

func orbit(delta: float = get_process_delta_time()):
	angle += delta * angular_velocity
	angle = fmod(angle, 2 * PI) ## This keeps the value range between 0 and 360 degrees
	
	var offset = Vector2(cos(angle), sin(angle)) * radius
	
	position = rotation_reference.position + offset


func return_cursor():
	show()
	in_battle = false
	

func activate_cursor():
	hide()
	in_battle = true


func duplicate_sprite():
	return sprite.duplicate()
	
	
func follow_target(_target: Node):
	target = _target
	following_target = true
	
	duplicated_cursor = duplicate_sprite()
	original_scale = duplicated_cursor.scale
	duplicated_cursor.scale *= new_scale_multiplier
	
	get_tree().root.add_child(duplicated_cursor)
	
	
func on_activated():
	activate_cursor()


func on_returned():
	return_cursor()
