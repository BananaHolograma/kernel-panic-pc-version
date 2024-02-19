class_name ButtonHazard extends Control

enum ROTATION_MODE {
	FULL_ROTATION,
	HALF_ROTATION,
	LINEAR
}

enum SPEED_MODE {
	CONSTANT,
	VARIANT
}

@export var current_rotation_mode := ROTATION_MODE.LINEAR
@export var current_speed_mode := SPEED_MODE.CONSTANT
@export var change_speed_after_seconds := 1
@export var min_speed := 80
@export var max_speed := 200

@export var direction := Vector2.RIGHT
@export var angle_step := deg_to_rad(15)

@onready var button = $Button
@onready var speed_variant_timer: Timer = $SpeedVariantTimer


var current_speed := randi_range(min_speed, max_speed)

	
func _ready():
	button.text = "Atttaaaack"
	current_rotation_mode = ROTATION_MODE.get(ROTATION_MODE.keys()[randi() % ROTATION_MODE.size()])
	current_speed_mode = SPEED_MODE.get(SPEED_MODE.keys()[randi() % SPEED_MODE.size()])
	
	if current_speed_mode == SPEED_MODE.VARIANT:
		speed_variant_timer.wait_time = change_speed_after_seconds
		speed_variant_timer.start()
	else:
		speed_variant_timer.stop()
		speed_variant_timer.autostart = false
		

func _physics_process(delta):
	position += delta * direction * current_speed
	
	match current_rotation_mode:
		ROTATION_MODE.FULL_ROTATION:
			rotation += angle_step
		ROTATION_MODE.HALF_ROTATION:
			if rotation + angle_step >= PI or rotation + angle_step <= -PI:
				angle_step *= -1 
			else:
				rotation += angle_step
		ROTATION_MODE.LINEAR:
			pass


func _on_speed_variant_timer_timeout():
	current_speed = randi_range(min_speed, max_speed)
