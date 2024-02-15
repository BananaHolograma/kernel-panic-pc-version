extends Control

signal finished_bootload

const FADE_OVERLAY = preload("res://ui/overlays/fade_overlay.tscn")
const FLASHING_CARET = preload("res://scenes/computer/flashing_caret.tscn")

@export var next_scene: String

@onready var start_screen: VBoxContainer = $MarginContainer/StartScreen
@onready var bios_info_container: VBoxContainer = $MarginContainer/StartScreen/HardDriveInfoContainer/VBoxContainer
@onready var hard_drive_info_container: VBoxContainer = $MarginContainer/StartScreen/HardDriveInfoContainer/VBoxContainer/MarginContainer/VBoxContainer
@onready var setup_container: MarginContainer = $MarginContainer/StartScreen/SetupContainer
@onready var caret_marker_final: Marker2D = $MarginContainer/CaretMarkerFinal
@onready var starting_windows: VBoxContainer = $MarginContainer/StartingWindows
@onready var logo: TextureRect = $Logo

@onready var detecting_hdd_labels := hard_drive_info_container.get_children()

func _ready():
	var overlay = FADE_OVERLAY.instantiate()
	overlay.fade_in_duration = 4.5
	overlay.auto_fade_in = false
	
	add_child(overlay)
	overlay.on_complete_fade_in.connect(fade_in_complete)
	
	overlay.fade_in()
	
	finished_bootload.connect(on_finished_bootload)


func fade_in_complete():	
	var tween: Tween = create_tween()
	tween.tween_property(bios_info_container, "visible", true, 0.5).from(false).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	while not detecting_hdd_labels.is_empty():
		var label = detecting_hdd_labels.pop_front()
		label.get_node("CaretMarker").add_child(FLASHING_CARET.instantiate())
		tween = create_tween()
		tween.tween_property(label, "visible", true, 0.7).from(false).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		
		label.get_node("CaretMarker/FlashingCaret").queue_free()
	
	await get_tree().create_timer(0.7).timeout
	setup_container.hide()
	caret_marker_final.add_child(FLASHING_CARET.instantiate())
	finished_bootload.emit()


func on_finished_bootload():
	await get_tree().create_timer(1).timeout
	
	start_screen.hide()
	logo.hide()
	caret_marker_final.hide()
	
	starting_windows.show()
	SceneTransitioner.next_scene_path = next_scene
	
	await get_tree().create_timer(1).timeout
	
	get_tree().call_deferred("change_scene_to_file", "res://scenes/loading/loading_screen.tscn")

