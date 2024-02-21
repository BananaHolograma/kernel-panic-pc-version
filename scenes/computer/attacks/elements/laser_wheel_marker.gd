class_name LaserWheelMarker extends Node2D

@export var aim_direction := Vector2.RIGHT
@export var rotation_speed := 1.0
@export var max_rotation_speed := 20
@export var rotation_acceleration := 3.5
@export var preparation_time := 4.5

@onready var preparation_timer: Timer = $PreparationTimer
@onready var laser_shoot_right = $RightMarker/LaserShoot
@onready var laser_shoot_bottom = $BottomMarker/LaserShoot
@onready var laser_shoot_left = $LeftMarker/LaserShoot
@onready var right_hitbox = $RightMarker/Hitbox2D/CollisionShape2D
@onready var bottom_hitbox = $BottomMarker/Hitbox2D/CollisionShape2D
@onready var left_hitbox = $LeftMarker/Hitbox2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var current_laser_sprite: AnimatedSprite2D
var current_hitbox: CollisionShape2D
var frame_count := 0 ## This is needed to detect the selected frame to enable the hitbox

func _ready():
	sprite_2d.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	right_hitbox.disabled = true
	left_hitbox.disabled = true
	bottom_hitbox.disabled = true
	
	preparation_timer.wait_time = preparation_time
	preparation_timer.one_shot = true
	preparation_timer.autostart = false
	
	match(aim_direction):
		Vector2.RIGHT:
			current_laser_sprite = laser_shoot_right
			current_hitbox = right_hitbox
		Vector2.LEFT:
			current_laser_sprite = laser_shoot_left
			current_hitbox = left_hitbox
		Vector2.DOWN:
			current_laser_sprite = laser_shoot_bottom
			current_hitbox = bottom_hitbox
	
	if current_laser_sprite:
		current_laser_sprite.frame_changed.connect(on_animation_frame_changed)
		current_laser_sprite.animation_finished.connect(on_animation_finished)
		current_laser_sprite.show()


func _process(delta):
	rotation_speed = clamp(rotation_speed + (rotation_acceleration * delta), 0, max_rotation_speed)
	sprite_2d.rotation += rotation_speed * delta


func shoot():
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.BLUE, preparation_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
	preparation_timer.start()


func _on_preparation_timer_timeout():
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	current_laser_sprite.play("shoot")


func on_animation_finished():
	right_hitbox.disabled = true
	left_hitbox.disabled = true
	bottom_hitbox.disabled = true
	
	sprite_2d.rotation = 0
	rotation_speed = 1.0
	frame_count = 0


func on_animation_frame_changed():
	frame_count += 1
	
	if frame_count == 4:
		current_hitbox.disabled = false
