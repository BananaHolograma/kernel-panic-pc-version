class_name LaserWheelMarker extends Node2D

signal finished

@export var aim_direction := Vector2.RIGHT
@export var rotation_speed := 1.5
@export var max_rotation_speed := 20
@export var rotation_acceleration := 4.5
@export var preparation_time := 1.85
@onready var preparation_timer: Timer = $PreparationTimer

@onready var laser_shoot_right = $RightMarker/LaserShoot
@onready var laser_shoot_bottom = $BottomMarker/LaserShoot
@onready var laser_shoot_left = $LeftMarker/LaserShoot
@onready var right_hitbox = $RightMarker/Hitbox2D/CollisionShape2D
@onready var bottom_hitbox = $BottomMarker/Hitbox2D/CollisionShape2D
@onready var left_hitbox = $LeftMarker/Hitbox2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var charge_stream_player: AudioStreamPlayer = $Charge
@onready var laser_stream_player: AudioStreamPlayer = $LaserBeam

const LASER_BEAM = preload("res://assets/sounds/LaserBeam.wav")
const LASER_WHEEL_CHARGE = preload("res://assets/sounds/laser_wheel_charge.ogg")
const LASER_WHEEL_CHARGE_2 = preload("res://assets/sounds/laser_wheel_charge_2.ogg")


var current_laser_sprite: AnimatedSprite2D
var current_hitbox: CollisionShape2D
var frame_count := 0 ## This is needed to detect the selected frame to enable the hitbox
var shooting := false:
	set(value):
		set_process(value)
		
		shooting = value
		

func _ready():
	sprite_2d.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	right_hitbox.disabled = true
	left_hitbox.disabled = true
	bottom_hitbox.disabled = true
	
	preparation_timer.wait_time = preparation_time
	preparation_timer.autostart = false
	preparation_timer.one_shot = true
	
	#charge_stream_player.finished.connect(on_finish_charge)
	
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
		
	finished.connect(on_finished)
	
	
func _process(delta):
	rotation_speed = clamp(rotation_speed + (rotation_acceleration * delta), 0, max_rotation_speed)
	sprite_2d.rotation += rotation_speed * delta


func shoot():
	shooting = true
	
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.BLUE, preparation_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	preparation_timer.start()
	charge_laser_sound()
	
	
func charge_laser_sound():
	charge_stream_player.stop()
	charge_stream_player.stream = [LASER_WHEEL_CHARGE, LASER_WHEEL_CHARGE_2].pick_random()
	charge_stream_player.pitch_scale = randf_range(0.8, 1.3)
	charge_stream_player.play()


func laser_beam_sound():
	laser_stream_player.stop()
	laser_stream_player.stream = LASER_BEAM
	laser_stream_player.pitch_scale = randf_range(0.8, 1.3)
	laser_stream_player.play()

	
func on_finish_charge():
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	current_laser_sprite.play("shoot")
	laser_beam_sound()


func on_animation_finished():
	finished.emit()


func on_animation_frame_changed():
	frame_count += 1
	
	if frame_count == 4:
		current_hitbox.disabled = false
		
	if frame_count == 8:
		current_hitbox.disabled = true


func on_finished():
	right_hitbox.disabled = true
	left_hitbox.disabled = true
	bottom_hitbox.disabled = true
	
	sprite_2d.rotation = 0
	rotation_speed = 1.0
	frame_count = 0
	shooting = false
	


func _on_preparation_timer_timeout():
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	current_laser_sprite.play("shoot")
	laser_beam_sound()

