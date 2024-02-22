extends Control

@onready var v_box_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer
@onready var back_arrow: TextureRect = $Panel/BackArrow

const NORMAL_COLOR = Color.BLACK
const HOVER_COLOR = Color("0000cc")

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel"):
		hide()


func _ready():
	make_available_external_links()
	back_arrow.gui_input.connect(on_back_arrow_pressed)


func on_back_arrow_pressed(event: InputEvent): 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hide()


func make_available_external_links():
	for child in v_box_container.get_children():
		if child is Label:
	
			child.gui_input.connect(on_label_pressed.bind(child))
			
			if Utilities.is_valid_url(child.text):
				child.mouse_filter = Control.MOUSE_FILTER_STOP
				child.mouse_entered.connect(on_label_hovered.bind(child))
				child.mouse_exited.connect(on_label_hover_exited.bind(child))


func on_label_pressed(event: InputEvent, label: Label):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Utilities.open_external_link(label.text)


func on_label_hovered(label: Label):
	label.add_theme_color_override("font_color", HOVER_COLOR)
	

func on_label_hover_exited(label: Label):
	label.add_theme_color_override("font_color", NORMAL_COLOR)
