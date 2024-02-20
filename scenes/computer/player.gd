class_name Player extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var motion_component: MotionComponent = $MotionComponent

@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var velocity_label: Label = %VelocityLabel
@onready var state_label: Label = %StateLabel

var locked := false
var is_left_direction: bool = false


func _ready():
	GameEvents.lock_player.connect(lock_player.bind(true))
	GameEvents.unlock_player.connect(lock_player.bind(false))
	
	finite_state_machine.state_changed.connect(on_state_changed)
	health_component.died.connect(on_died)
	
	
func _process(_delta):
	#_update_sprite_flip()
	
	velocity_label.text = str(velocity)


#func _update_sprite_flip():
	#is_left_direction = motion_component.last_faced_direction.x < 0
	#
	#if animated_sprite_2d.flip_h != is_left_direction:
		#animated_sprite_2d.flip_h = is_left_direction


func lock_player(lock : bool) -> void:
	if finite_state_machine:
		if lock:
			locked = true
			finite_state_machine.lock_state_machine()
		else:
			locked = false
			finite_state_machine.unlock_state_machine()


func reduce_speed(new_speed: float):
	motion_component.change_speed_temporary(new_speed)


func on_state_changed(from_state: State, state: State):
	state_label.text = "%s --> %s" % [from_state.name, state.name]


func _on_hurtbox_2d_hitbox_detected(hitbox):
	if hitbox.name == "LaserHitbox":
		reduce_speed(motion_component.max_speed / 2)
	else:
		health_component.damage(1)

		if not health_component.check_is_dead() and not health_component.IS_INVULNERABLE:
			health_component.enable_invulnerability(true, 2.0)


func on_died():
	print("player died")
