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

### SAVE & LOAD ###
signal deleted_saved_game(filename: String)
