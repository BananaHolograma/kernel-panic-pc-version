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
	
	
func on_state_changed(from_state: State, state: State):
	state_label.text = "%s --> %s" % [from_state.name, state.name]
