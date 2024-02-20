class_name BinElement extends Node2D

signal spawned

@onready var line_2d: Line2D = $Line2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var visual_feedback_timer: Timer = $VisualFeedbackTimer


var id: String
var texture: Texture2D
var origin_position := Vector2.ZERO
var spawn_position := Vector2.ZERO
var cursor_to_show: Sprite2D

var visual_feedback_time := 1.5


func _ready():
	set_process(false)
	
	sprite_2d.texture = texture
	add_child(cursor_to_show)
	
	spawned.connect(on_spawned)
	visual_feedback_timer.timeout.connect(on_visual_feedback_ended)
	visual_feedback_timer.autostart = false
	visual_feedback_timer.wait_time = visual_feedback_time
	
	spawn()

	
func _process(delta):
	if id == "search":
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
	set_process(true)
	visual_feedback_timer.one_shot = true
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
	line_2d.points.clear()
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
	line_2d.default_color = Color.BROWN
	set_process(false)
