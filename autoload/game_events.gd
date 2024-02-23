extends Node

### PLAYER ###
signal lock_player
signal unlock_player
signal winned_game
signal losed_game
signal game_started

### INTERACTIONS ###
signal interacted(interactable: Interactable)
signal cancel_interact(interactable: Interactable)
signal focused(interactable: Interactable)
signal unfocused(interactable: Interactable)

### UI ###
signal show_pause_menu
signal hidden_pause_menu

### SAVE & LOAD ###
signal deleted_saved_game(filename: String)

@onready var screen_mode := DisplayServer.WINDOW_MODE_FULLSCREEN
@onready var screen_resolution := Vector2(1280, 720)
@onready var master_volume := 1.0
@onready var music_volume := 0.8
@onready var sfx_volume := 0.9


func _ready():
	if OS.get_name() == "Web":
		screen_mode = DisplayServer.WINDOW_MODE_WINDOWED
		screen_resolution = get_viewport().get_visible_rect().size

