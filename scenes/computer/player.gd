class_name Player extends CharacterBody2D

signal before_dead
signal died

@export var teleport_distance := 35

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var motion_component: MotionComponent = $MotionComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var wall_teleport_detector: RayCast2D = $WallTeleportDetector

@onready var teleport_cooldown_bar: TextureProgressBar = %TeleportCooldownBar
@onready var health_bar: TextureProgressBar = $HealthFeedback/HealthBar
@onready var appear_vfx: Control = $AppearVFX

@onready var teleport_audio_stream_player: AudioStreamPlayer = $TeleportAudioStreamPlayer
@onready var hit_audio_stream_player: AudioStreamPlayer = $Hit
@onready var dead_sound: AudioStreamPlayer = $DeadSound

@onready var dead_particles: GPUParticles2D = $DeadParticles


const REDUCED_SPEED_PARTICLES = preload("res://scenes/computer/attacks/elements/reduced_speed_particles.tscn")

var locked := false
var is_left_direction: bool = false
var teleporting := false
var alive := true

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("dash"):
		teleport()


func _process(_delta):
	display_cooldown_feedback()


func _ready():
	GameEvents.lock_player.connect(lock_player.bind(true))
	GameEvents.unlock_player.connect(lock_player.bind(false))
	
	teleport_cooldown_bar.hide()
	health_bar.hide()
	health_bar.value = health_component.CURRENT_HEALTH
	
	motion_component.teleport_cooldown_ended.connect(func():
		teleport_cooldown_bar.value = 0	
		teleport_cooldown_bar.hide()
	)
	
	motion_component.teleported.connect(on_teleported)
	health_component.health_changed.connect(on_health_changed)
	health_component.died.connect(on_died)
	health_component.invulnerability_changed.connect(on_invulnerability_changed)
	animation_player.animation_finished.connect(on_animation_finished)
	

func on_health_changed(amount: int, _type: HealthComponent.TYPES):
	if amount > 0 and alive:
		show_health_feedback()
	
	
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


#Normalization: Using 1 - time_left/cooldown ensures accurate progress calculation.
#Bar Range: Ensure your teleport_cooldown_bar has a max_value of 1 or a suitable value based on your scaling preferences.
func display_cooldown_feedback():
	if motion_component.teleport_cooldown_timer.time_left > 0:
		var progress = snapped((1 - motion_component.teleport_cooldown_timer.time_left / motion_component.teleport_cooldown), teleport_cooldown_bar.step)
		teleport_cooldown_bar.value = progress
		
	
func show_health_feedback():	
	health_bar.value = max(0, health_component.CURRENT_HEALTH)
	health_bar.show()
	

func appear():
	animation_player.play("appear")
	
	
func teleport():
	var direction = finite_state_machine.current_state.input_direction
	
	if not direction.is_zero_approx() \
		and not wall_teleport_detector.is_colliding() \
		and not finite_state_machine.current_state is Idle:
		motion_component.teleport_to(direction * teleport_distance)


func teleport_effect(_spawn_position: Vector2):
	if animated_sprite_2d:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = animated_sprite_2d.sprite_frames.get_frame_texture(animated_sprite_2d.animation, animated_sprite_2d.frame)

		get_tree().root.add_child(sprite)
		
		sprite.global_position = _spawn_position
		sprite.scale = animated_sprite_2d.scale
		sprite.flip_h = animated_sprite_2d.flip_h
		sprite.flip_v = animated_sprite_2d.flip_v
		#sprite.modulate = Color(249.0, 58.0, 59.0, 0.75)
		var tween: Tween = create_tween()
		
		tween.tween_property(sprite, "modulate:a", 0.0, 0.7).set_trans(tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_callback(sprite.queue_free)
	
	teleport_audio_stream_player.play()
	
	
func on_teleported(previous_position: Vector2, new_position: Vector2):
	teleport_cooldown_bar.show()
	
	teleport_effect(previous_position)
	teleport_effect(previous_position + (finite_state_machine.current_state.input_direction * teleport_distance))
	teleport_effect(previous_position + (finite_state_machine.current_state.input_direction * (teleport_distance + 15)))
	teleport_effect(new_position)
	teleport_effect(new_position + (finite_state_machine.current_state.input_direction * teleport_distance))
	teleport_effect(new_position + (finite_state_machine.current_state.input_direction * (teleport_distance + 15)))
	
	health_component.enable_invulnerability(true, 1.5)


func on_invulnerability_changed(active: bool):
	if not active and animation_player.is_playing() and animation_player.current_animation == "hit":
		animation_player.stop()
		animated_sprite_2d.material.set_shader_parameter("flash_opacity", 0)
		health_bar.hide()
			

func on_died():
	if alive:
		before_dead.emit()
		alive = false
		var tween = create_tween()
		tween.tween_property(animated_sprite_2d, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_OUT)
		
		health_bar.hide()
		teleport_cooldown_bar.hide()
		dead_sound.play()
		dead_particles.emitting = true
		

func _on_hurtbox_2d_hitbox_detected(hitbox):
	if hitbox.name == "LaserHitbox":
		reduce_speed(motion_component.max_speed / 2)
	else:
		health_component.damage(1)
		
		if not health_component.check_is_dead() and not health_component.IS_INVULNERABLE:
			health_component.enable_invulnerability(true, 2.0)
			animation_player.play("hit")
			hit_audio_stream_player.play()


func on_animation_finished(animation_name: String):
	if animation_name == "appear":
		appear_vfx.hide()


func _on_dead_particles_finished():
	died.emit()
