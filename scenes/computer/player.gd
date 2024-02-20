class_name Player extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var motion_component: MotionComponent = $MotionComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine

const REDUCED_SPEED_PARTICLES = preload("res://scenes/computer/attacks/elements/reduced_speed_particles.tscn")

var locked := false
var is_left_direction: bool = false


func _ready():
	GameEvents.lock_player.connect(lock_player.bind(true))
	GameEvents.unlock_player.connect(lock_player.bind(false))

	health_component.died.connect(on_died)
	health_component.invulnerability_changed.connect(func(active: bool):
		if not active and animation_player.is_playing() and animation_player.current_animation == "hit":
			animation_player.stop()
			animated_sprite_2d.material.set_shader_parameter("flash_opacity", 0)
	)
	

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
	
	if get_node_or_null("ReducedSpeedParticles") == null:
		var reduced_speed_vfx = REDUCED_SPEED_PARTICLES.instantiate()
		reduced_speed_vfx.time_alive = motion_component.default_speed_temporary_time
		add_child(reduced_speed_vfx)


func _on_hurtbox_2d_hitbox_detected(hitbox):
	if hitbox.name == "LaserHitbox":
		reduce_speed(motion_component.max_speed / 2)
	else:
		health_component.damage(1)
		
		if not health_component.check_is_dead() and not health_component.IS_INVULNERABLE:
			health_component.enable_invulnerability(true, 2.0)
			animation_player.play("hit")


func on_died():
	print("player died")
	get_tree().paused = true
