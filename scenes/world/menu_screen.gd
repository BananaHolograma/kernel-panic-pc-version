extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_button: Button = %StartButton
@onready var options_button: Button = %OptionsButton
@onready var credits: Button = %Credits
@onready var exit: Button = %Exit
@onready var exit_confirmation: ConfirmationDialog = $ContentMarginContainer/ExitConfirmation
@onready var version: Label = %Version
@onready var options_menu: Control = %OptionsMenu

const BOOTLOADER = preload("res://scenes/computer/bootloader.tscn")
	
		
func _ready():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	DisplayServer.window_set_mode(GameEvents.screen_mode)
	DisplayServer.window_set_size(GameEvents.screen_resolution)
	
	animation_player.play("title_blink")
	exit_confirmation.confirmed.connect(func(): get_tree().quit())
	
	start_button.grab_focus()
	
	version.text = ProjectSettings.get_setting("application/config/version")


func _on_exit_pressed():
	exit_confirmation.popup_centered()


func _on_start_button_pressed():
	get_tree().call_deferred("change_scene_to_packed", BOOTLOADER)


func _on_itch_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Utilities.open_external_link("https://bananaholograma.itch.io/")
		
		
func _on_instagram_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Utilities.open_external_link("https://instagram.com/bananaholograma")


func _on_github_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Utilities.open_external_link("https://github.com/bananaholograma")


func _on_options_button_pressed():
	options_menu.show()
