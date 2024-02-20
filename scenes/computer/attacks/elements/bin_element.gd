class_name BinElement extends Node2D

signal visual_feedback_ended
signal spawned
signal finished

const BEAM = preload("res://assets/sounds/Beam.ogg")
const LASER = preload("res://assets/sounds/Laser.ogg")

@onready var line_2d: Line2D = $Line2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var visual_feedback_timer: Timer = $VisualFeedbackTimer
@onready var laser_hitbox: CollisionPolygon2D = $LaserHitbox/CollisionPolygon2D


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

func _ready():
	sprite_2d.texture = texture
	add_child(cursor_to_show)
	
	spawned.connect(on_spawned)
	visual_feedback_timer.timeout.connect(on_visual_feedback_ended)
	spawn()

	
func _process(_delta):
	if id == "search":
		if aiming:
			visual_feedback_aim_player()
		
		
func spawn():
	var tween = create_tween()
	tween.tween_property(self, "global_position", spawn_position, 1.0)\
		.from(origin_position)\
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
		"text_file_2":
			text_file_2_attack()


func movies_attack():
	pass



func search_attack():
	aiming = true
	line_2d.width = laser.aim.width

	visual_feedback_timer.autostart = false
	visual_feedback_timer.one_shot = true
	visual_feedback_timer.wait_time = laser.aim.visual_feedback_time
	visual_feedback_timer.start()
	
	
func music_attack():
	pass
	
	
func text_file_attack():
	pass
	
	
func text_file_2_attack():
	pass


func world_attack():
	pass


func visual_feedback_aim_player():
	line_2d.clear_points()
	line_2d.points = PackedVector2Array([Vector2.ZERO, to_local(player.global_position)])

	
func set_id(_id: String) -> BinElement:
	id = _id
	
	return self
	
	
func set_texture(_texture: Texture2D) -> BinElement:
	texture = _texture
	
	return self


func on_spawned():
	cursor_to_show.queue_free()
	start()


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
	
	await get_tree().create_timer(0.5).timeout
	queue_free()
