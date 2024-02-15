extends Control

@export var icon_texture: CompressedTexture2D
@export var icon_name: String
@export var icon_size := Vector2(32, 32)
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $TextureRect/Label
@onready var focused_bg: ColorRect = $FocusedBG

func _ready():
	if icon_texture:
		texture_rect.texture = icon_texture
		
	label.text = icon_name
	
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.size = icon_size


func _on_focus_entered():
	focused_bg.show()


func _on_focus_exited():
	focused_bg.hide()
