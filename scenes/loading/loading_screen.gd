extends Control

signal failed(status: ResourceLoader.ThreadLoadStatus)
signal finished

@onready var progress := []
@onready var scene_load_status := ResourceLoader.THREAD_LOAD_IN_PROGRESS

@export var next_scene_path: String
var loading := false

func _ready():
	next_scene_path = SceneTransitioner.next_scene_path
	finished.connect(on_finished)
	failed.connect(on_failed)
	
	if not next_scene_path.is_empty() and next_scene_path.is_absolute_path():
		ResourceLoader.load_threaded_request(next_scene_path)
		loading = true
		
		
func _process(_delta):
	if loading:
		var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			finished.emit()
		else:
			if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				failed.emit(status)


func on_finished():
	loading = false
	SceneTransitioner.next_scene_path = ""
	get_tree().call_deferred("change_scene_to_packed", ResourceLoader.load_threaded_get(next_scene_path))
		

func on_failed(_status: ResourceLoader.ThreadLoadStatus):
	push_error("Error loading the scene %s with status %s" % [SceneTransitioner.next_scene_path, str(_status)])
	loading = false
	SceneTransitioner.next_scene_path = ""
