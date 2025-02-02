class_name ButtonHazard extends Control

#const BEEP = preload("res://assets/sounds/beep.ogg")
#const BEEP_2 = preload("res://assets/sounds/beep_2.ogg")

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
@export var change_speed_after_seconds := 1.5
@export var change_angle_after_seconds := 0
@export var change_direction_after_seconds := 2.5
@export var change_direction_probability := 0.45
@export var min_speed := 75
@export var max_speed := 150

@export var direction := Vector2.RIGHT
@export var min_angle_step := 5
@export var max_angle_step := 10

@onready var button = $Button
@onready var speed_variant_timer: Timer = $SpeedVariantTimer
@onready var angle_step_variant_timer: Timer = $AngleStepVariantTimer
@onready var change_direction_timer: Timer = $ChangeDirectionTimer
@onready var hitbox: CollisionShape2D = %ButtonHitbox/CollisionShape2D

@onready var speed := randi_range(min_speed, max_speed)
@onready var angle_step := deg_to_rad(randi_range(min_angle_step, max_angle_step))


func _ready():
	button.text = random_text()
	current_rotation_mode = ROTATION_MODE.get(ROTATION_MODE.keys()[randi() % ROTATION_MODE.size()])
	current_speed_mode = SPEED_MODE.get(SPEED_MODE.keys()[randi() % SPEED_MODE.size()])
	
	GameEvents.losed_game.connect(func(): queue_free())
	GameEvents.winned_game.connect(func(): queue_free())
	
	prepare_timers()
	prepare_hitbox()
	

func prepare_timers():
	if current_speed_mode == SPEED_MODE.VARIANT and change_speed_after_seconds > 0:
		speed_variant_timer.wait_time = change_speed_after_seconds
		speed_variant_timer.start()
	else:
		speed_variant_timer.stop()
		speed_variant_timer.autostart = false
		
	if current_rotation_mode != ROTATION_MODE.LINEAR and change_angle_after_seconds > 0:
		angle_step_variant_timer.wait_time = change_speed_after_seconds
		angle_step_variant_timer.start()
	else:
		angle_step_variant_timer.stop()
		angle_step_variant_timer.autostart = false
		
	if change_direction_after_seconds:
		change_direction_timer.stop()
		change_direction_timer.wait_time = change_direction_after_seconds
		change_direction_timer.autostart = false
		change_direction_timer.one_shot = true
		change_direction_timer.start()


func prepare_hitbox():
	# We need this timeout to not hitbox the player on the spawn and set the hitbox properly
	await get_tree().create_timer(5.0 / Engine.physics_ticks_per_second).timeout
	
	hitbox.position = Vector2(0, button.size.y / 2)
	hitbox.shape = RectangleShape2D.new()
	hitbox.shape.extents = Vector2(button.size.x / 2, button.size.y / 2)
	
		
	
func _physics_process(delta):
	position += delta * direction * speed
	
	match current_rotation_mode:
		ROTATION_MODE.FULL_ROTATION:
			rotation += angle_step
		ROTATION_MODE.HALF_ROTATION:
			if rotation + angle_step >= PI or rotation + angle_step <= -PI:
				angle_step *= -1 
			else:
				rotation += angle_step


func random_text() -> String:
	var texts = ["Upload photo","Advanced options", "Reset", ":(){ :|:& };:", "^_^", "Super extreme hell panic button that can be used as a wall",  "ASCII", "Buy", "-_-", "'_'", "o_o", "<_<", ">_<", "xD", "BananaHolograma", "BUP BIP BOP", "BIP", "BOP", "Loading...", "Emoticon extermination",  "Pizza fueled", "Stack Overflow", "Code crush", "Alt + f4", "Blue Screen", "Cat video distraction", "System update", "Download", "Upload", "Read", "Accept", "Cancel", "Nerds assemble!", "Error 404", "Allergic to sunshine", "Ctrl + alt + delete", "Level up your Doom"]

	return texts.pick_random()
	
	
func _on_speed_variant_timer_timeout():
	speed = randi_range(min_speed, max_speed)


func _on_angle_step_variant_timer_timeout():
	angle_step = deg_to_rad(randi_range(min_angle_step, max_angle_step))


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_change_direction_timer_timeout():
	if randf() <= change_direction_probability:
		var new_direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	  
		while new_direction.is_zero_approx() or new_direction.is_equal_approx(direction):
			new_direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
			
		direction = new_direction
