extends Node2D

@export var time_alive := 1.0

@onready var timer: Timer = $Timer


func _ready():
	name = "ReducedSpeedParticles"
	timer.timeout.connect(on_timeout)
	timer.wait_time = time_alive
	timer.autostart = false
	timer.one_shot = true
	timer.start()


func on_timeout():
	queue_free()
