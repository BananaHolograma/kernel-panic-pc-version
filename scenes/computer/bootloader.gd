extends Control

const FADE_OVERLAY = preload("res://ui/overlays/fade_overlay.tscn")


func _ready():
	var overlay = FADE_OVERLAY.instantiate()
	overlay.fade_in_duration = 4.5
	overlay.auto_fade_in = false
	
	add_child(overlay)
	
	overlay.fade_in()

