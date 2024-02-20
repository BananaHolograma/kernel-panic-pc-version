class_name BinElement extends Node2D

signal visual_feedback_ended
signal spawned
signal finished

const BEAM = preload("res://assets/sounds/Beam.ogg")
const LASER = preload("res://assets/sounds/Laser.ogg")
const WORLD_EXPLOSION = preload("res://assets/vfx/world_explosion.png")
const WORLD_EXPLOSION_SOUND = preload("res://assets/sounds/WorldExplosion.wav")
const TEXT_FILE_SHOOT = preload("res://assets/sounds/text_file_shoot.wav")
const TEXT_FILE_SHOOT_2 = preload("res://assets/sounds/text_file_shoot_2.wav")
const TEXT_FILE_SHOOT_3 = preload("res://assets/sounds/text_file_shoot_3.wav")

const SPEAKER = preload("res://scenes/computer/attacks/elements/speaker.tscn")
const TEXT_FILE_LETTER = preload("res://scenes/computer/attacks/elements/text_file_letter.tscn")

@onready var line_2d: Line2D = $LaserLine2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var visual_feedback_timer: Timer = $VisualFeedbackTimer
@onready var time_active_timer: Timer = $TimeActiveTimer
@onready var laser_hitbox: CollisionPolygon2D = $LaserHitbox/CollisionPolygon2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var world_vfx: AnimatedSprite2D = %WorldVFX
@onready var world_radius_explosion: CollisionShape2D = %WorldRadiusExplosion

var antivirus: Antivirus
var params := {}
var id: String
var texture: Texture2D
var origin_position := Vector2.ZERO
var spawn_position := Vector2.ZERO
var cursor_to_show: Sprite2D
var aiming := false
var hitbox_delay := 0.3

var laser := {
	"aim": {
		"visual_feedback_time": 1.5,
		"width": 30
	},
	"shoot": {
		"width": 50
	}
}


func _exit_tree():
	finished.emit()


func _ready():
	sprite_2d.texture = texture
	add_child(cursor_to_show)
	
	spawned.connect(on_spawned)
	visual_feedback_timer.timeout.connect(on_visual_feedback_ended)
	time_active_timer.timeout.connect(on_time_active_ended)
	animation_player.animation_finished.connect(on_animation_finished)
	spawn()

	
func _process(_delta):
	if id == "search":
		if aiming:
			visual_feedback_aim_player()
		
		
func spawn():
	var tween = create_tween()
	tween.tween_property(self, "position", spawn_position, 2.0)\
		.from(to_local(origin_position))\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
	await tween.finished
	
	spawned.emit()


func start():
	match id:
		"movies":
			movies_attack()
		"search":
			search_attack()
		"music":
			music_attack()
		"world":
			world_attack()
		"text_file":
			text_file_attack()
func movies_attack():
	pass



func search_attack():
	aiming = true
	line_2d.width = laser.aim.width
	line_2d.modulate.a = 0
	
	visual_feedback_timer.autostart = false
	visual_feedback_timer.one_shot = true
	visual_feedback_timer.wait_time = laser.aim.visual_feedback_time
	visual_feedback_timer.start()
	
	var tween = create_tween()
	tween.tween_property(line_2d, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)

	
func music_attack():
	time_active_timer.wait_time = params.time_active
	
	for i in range(randi_range(1, params.max_speakers_amount)):
		var speaker = SPEAKER.instantiate() as Speaker
		add_child(speaker)
	
	time_active_timer.start()


func text_file_attack():
	var current_angle = 0
	var angle_step = params.angle_step
	
	for i in range(params.pulses):
		var sfx = AudioStreamPlayer.new()
		sfx.bus = "SFX"
		sfx.pitch_scale = randf_range(0.95, 1.3)
		sfx.stream = [TEXT_FILE_SHOOT, TEXT_FILE_SHOOT_2, TEXT_FILE_SHOOT_3].pick_random()
		add_child(sfx)
		sfx.play()

		while current_angle <= rad_to_deg(PI * 2):
			current_angle += angle_step
			var letter = TEXT_FILE_LETTER.instantiate() as TextFileLetter
			letter.angle = current_angle
			letter.global_position = global_position
			get_tree().root.add_child(letter)
			
		
		current_angle = 0
		if params.pulses > 1:
			await get_tree().create_timer(params.time_between_pulses).timeout
	
	await get_tree().create_timer(1.0).timeout
	scale_dissapear_animation()
	
	
func scale_dissapear_animation():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.finished.connect(func(): queue_free())
	

func world_attack():
	world_vfx.show()
	animation_player.play("world_explosion")
	world_radius_explosion.disabled = false
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_OUT)
	
	var sfx = AudioStreamPlayer.new()
	sfx.bus  = "SFX"
	sfx.pitch_scale = randf_range(0.75, 1.5)
	sfx.stream = WORLD_EXPLOSION_SOUND
	add_child(sfx)
	sfx.play()
	

func visual_feedback_aim_player():
	line_2d.clear_points()
	line_2d.points = PackedVector2Array([Vector2.ZERO, to_local(player.global_position)])

	
func set_id(_id: String) -> BinElement:
	id = _id
	
	return self
	
	
func set_texture(_texture) -> BinElement:
	var new_texture = _texture
	
	if new_texture is Array:
		new_texture = _texture.pick_random()
		
	texture = new_texture
	
	return self


func on_spawned():
	cursor_to_show.queue_free()
	start()


func on_animation_finished(animation_name: String):
	if animation_name == "world_explosion":
		world_vfx.hide()
		world_radius_explosion.disabled = true
		finished.emit()
		queue_free()


func on_visual_feedback_ended():
	aiming = false
	
	var sfx = AudioStreamPlayer.new()
	sfx.bus = "SFX"
	sfx.stream = [BEAM, LASER].pick_random()
	sfx.pitch_scale = randf_range(0.75, 1.5)
	add_child(sfx)
	sfx.play()
	
	line_2d.width = laser.shoot.width
	line_2d.add_point(line_2d.get_point_position(1) * 5)
	laser_hitbox.disabled = true
	laser_hitbox.set_polygon(line_2d.points)
	
	await get_tree().create_timer(0.65).timeout
	laser_hitbox.disabled = false
	
	var tween = create_tween()
	tween.tween_property(line_2d, "modulate:a", 0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)

	await get_tree().create_timer(0.5).timeout
	scale_dissapear_animation()


func on_time_active_ended():
	scale_dissapear_animation()
