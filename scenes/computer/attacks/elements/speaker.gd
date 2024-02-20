class_name Speaker extends Node2D

@onready var amplitude_x = randf_range(20.0, 45.0)  
@onready var amplitude_y = randf_range(25.0, 50.0) 
@onready var frequency_x = randf_range(1.5, 5.0)   
@onready var frequency_y = randf_range(1.0, 5.5)
@onready var offset = randf_range(0, 0.5)

var time := 0.01


func _physics_process(delta):
	time += delta
	position = Vector2(sin(time * frequency_x) * amplitude_x + offset, sin(time * frequency_y) * amplitude_y + offset)

