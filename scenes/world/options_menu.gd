extends Control

@onready var music_slider: HSlider = %MusicSlider
@onready var sound_effects_slider: HSlider = %SoundEffectsSlider
@onready var master_slider: HSlider = %MasterSlider

@onready var screen_mode_options_button: OptionButton = %ScreenModeOptionsButton
@onready var resolution_options_button: OptionButton = %ResolutionOptionsButton


func _unhandled_key_input(_event: InputEvent):
	if Input.is_action_just_pressed("pause") and not visible:
		open()
		
	if Input.is_action_just_pressed("ui_cancel") and visible:
		close()


func _ready():
	hide()
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	AudioManager.change_volume("Music", GameEvents.music_volume)
	AudioManager.change_volume("SFX", GameEvents.sfx_volume)
	
	music_slider.value = GameEvents.music_volume
	sound_effects_slider.value = GameEvents.sfx_volume
	master_slider.value = GameEvents.master_volume
	
	music_slider.grab_focus()
	
	screen_mode_options_button.select(1 if GameEvents.screen_mode == DisplayServer.WINDOW_MODE_FULLSCREEN else 0)
	var resolution_option_index = 0
	
	match GameEvents.screen_resolution:
		Vector2(960, 540):
			resolution_option_index = 0
		Vector2(1280, 720):
			resolution_option_index = 1
		Vector2(1440, 810):
			resolution_option_index = 2
		Vector2(1920, 1080):
			resolution_option_index = 3
	
	resolution_options_button.select(resolution_option_index)
	
	if GameEvents.screen_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		resolution_options_button.disabled = true
	

func open():
	show()
	GameEvents.show_pause_menu.emit()
	
	
func close():
	hide()
	GameEvents.hidden_pause_menu.emit()


func _change_screen_resolution(id: int):
	var resolution := GameEvents.screen_resolution
	
	match id:
		1:
			resolution = Vector2(960, 540)
		2:
			resolution = Vector2(1280, 720)
		3:
			resolution = Vector2(1440, 810)
		4:
			resolution = Vector2(1920, 1080)
	
	GameEvents.screen_resolution = resolution
	DisplayServer.window_set_size(resolution)


func _change_window_mode(id: int):
	match id:
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			resolution_options_button.disabled = false
			GameEvents.screen_mode = DisplayServer.WINDOW_MODE_WINDOWED
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			resolution_options_button.disabled = true
			GameEvents.screen_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		

func _on_screen_mode_options_button_item_selected(index: int):
	_change_window_mode(screen_mode_options_button.get_item_id(index))


func _on_resolution_options_button_item_selected(index: int):
	_change_screen_resolution(resolution_options_button.get_item_id(index))


func _on_music_slider_value_changed(value):
	AudioManager.change_volume("Music", value)
	GameEvents.music_volume = value


func _on_sound_effects_slider_value_changed(value):
	AudioManager.change_volume("SFX", value)
	GameEvents.sfx_volume = value


func _on_close_button_pressed():
	close()


func _on_master_slider_value_changed(value):
	AudioManager.change_volume("Master", value)
	GameEvents.master_volume = value


func _on_visibility_changed():
	if visible:
		music_slider.grab_focus()
