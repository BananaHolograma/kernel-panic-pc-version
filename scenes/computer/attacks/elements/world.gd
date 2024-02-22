class_name World extends Node2D

const WORLD_EXPLOSION_SOUND = preload("res://assets/sounds/WorldExplosion.wav")

@onready var world_vfx: AnimatedSprite2D = %WorldVFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var world_radius_explosion: CollisionShape2D = %WorldRadiusExplosion
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var probability_to_line_explosions := 1.0
@export var number_of_explosions := 20
@export var separation_between_explosions := 50

var is_root_explosion := false

func _ready():
	world_vfx.show()
	animation_player.play("world_explosion")
	world_radius_explosion.disabled = false
	
	var sfx = AudioStreamPlayer.new()
	sfx.bus  = "SFX"
	sfx.pitch_scale = randf_range(0.75, 1.5)
	sfx.stream = WORLD_EXPLOSION_SOUND
	add_child(sfx)
	sfx.play()
	
	create_line_explosions()


func create_line_explosions():
	if is_root_explosion and randf() <= probability_to_line_explosions:
		var new_direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	  
		while new_direction.is_zero_approx():
			new_direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
			
		var count = 0
		
		for i in range(number_of_explosions):
			count += 1
			var new_world = self.duplicate()
			new_world.position += new_direction * (separation_between_explosions * count) 
			get_parent().add_child(new_world)


func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "world_explosion":
		world_radius_explosion.disabled = true
		queue_free()
