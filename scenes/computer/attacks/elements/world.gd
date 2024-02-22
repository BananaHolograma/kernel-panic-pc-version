class_name World extends Node2D

signal finished

const WORLD_EXPLOSION_SOUND = preload("res://assets/sounds/WorldExplosion.wav")

@onready var world_vfx: AnimatedSprite2D = %WorldVFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var world_radius_explosion: CollisionShape2D = %WorldRadiusExplosion
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var indicator_rotation_point: Node2D = $IndicatorRotationPoint
@onready var indicator: Sprite2D = $IndicatorRotationPoint/Indicator

@export var probability_to_line_explosions := 0.05
@export var number_of_explosions := 20
@export var separation_between_explosions := 35

var is_root_explosion := false
var visual_feedback := false

func _ready():
	finished.connect(on_finished)
	
	indicator_rotation_point.modulate.a = 0
	world_vfx.show()
	animation_player.play("world_explosion")
	world_radius_explosion.disabled = false
	
	var sfx = AudioStreamPlayer.new()
	sfx.bus  = "SFX"
	sfx.pitch_scale = randf_range(0.75, 1.5)
	sfx.stream = WORLD_EXPLOSION_SOUND
	add_child(sfx)
	sfx.play()
	
	if is_root_explosion:
		create_line_explosions()


func create_line_explosions():
	if randf() <= probability_to_line_explosions:
		visual_feedback = true
		var new_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	  
		while new_direction.is_zero_approx():
			new_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
			
		var count = 0
		
		print("PUTA DIRECCION DE MIERDA ", new_direction)
		print("puta mierda coño ", indicator_rotation_point.position.angle_to_point(position * new_direction))
		print("puta existencia ya ",  indicator_rotation_point.position)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(indicator_rotation_point, "modulate:a", 1.0, 1.2).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(indicator_rotation_point, "rotation", Vector2.UP.angle_to(new_direction), 1.2)\
			.set_ease(Tween.EASE_IN)
		
		await tween.finished
		await get_tree().create_timer(1.0).timeout ## Time to detect the feedback and react
				
		for i in range(number_of_explosions):
			count += 1
			var new_world = self.duplicate()
			new_world.position = position + new_direction * (separation_between_explosions * count) 
			get_parent().add_child(new_world)
		
		finished.emit()


func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "world_explosion":
		world_radius_explosion.disabled = true
		
		if not visual_feedback:
			finished.emit()
	
		
func on_finished():
	queue_free()
