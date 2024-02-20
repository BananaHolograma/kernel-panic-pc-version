class_name BinElement extends Node2D

signal spawned


@onready var sprite_2d: Sprite2D = $Sprite2D

var id: String
var texture: Texture2D
var origin_position := Vector2.ZERO
var spawn_position := Vector2.ZERO
var cursor_to_show: Sprite2D

func _ready():
	sprite_2d.texture = texture
	
	spawned.connect(on_spawned)
	spawn()
	add_child(cursor_to_show)
	

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
			pass


func set_id(_id: String) -> BinElement:
	id = _id
	
	return self
	
	
func set_texture(_texture: Texture2D) -> BinElement:
	texture = _texture
	
	return self


func on_spawned():
	cursor_to_show.queue_free()
	start()


