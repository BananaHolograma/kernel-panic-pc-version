class_name Player extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var motion_component: MotionComponent = $MotionComponent

@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine

var is_left_direction: bool = false


func _process(delta):
	_update_sprite_flip()


func _update_sprite_flip():
	is_left_direction = motion_component.last_faced_direction.x < 0
	
	if animated_sprite_2d.flip_h != is_left_direction:
		animated_sprite_2d.flip_h = is_left_direction
