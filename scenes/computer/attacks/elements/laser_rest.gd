extends Node2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var timer: Timer = $Timer


func _ready():
	gpu_particles_2d.emitting = true
	

func _on_timer_timeout():
	queue_free()
