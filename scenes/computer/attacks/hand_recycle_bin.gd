class_name HandRecycleBin extends Attack

const MOVIES = preload("res://ui/themes/classic-95/icons/movies.png")
const MUSIC = preload("res://ui/themes/classic-95/icons/music.png")
const SEARCH = preload("res://ui/themes/classic-95/icons/search.png")
const TEXT_FILE = preload("res://ui/themes/classic-95/icons/text_file.png")
const TEXT_FILE_2 = preload("res://ui/themes/classic-95/icons/text_file_2.png")
const WORLD = preload("res://ui/themes/classic-95/icons/world.png")

const BIN_ELEMENT = preload("res://scenes/computer/attacks/elements/bin_element.tscn")


@export var elements_to_grab := 3


var available_elements := {
	"movies": {
		"texture": MOVIES,
		"params": {}
	},
	"search": {
		"texture": SEARCH,
		"params": {}
	},
	"music": {
		"texture": MUSIC,
		"params": {}
	},
	"text_file": {
		"texture": TEXT_FILE,
		"params": {}
	},
	"text_file_2": {
		"texture": TEXT_FILE_2,
		"params": {}
	},
	"world": {
		"texture": WORLD,
		"params": {}
	},
}


func _ready():
	finished.connect(on_finished)
	

func start():
	send_cursor_to_target()
	
	await focused_target
	
	for element in ["music", "music"]: ## Temporary, change it to pick_random_elements() fn
		duplicated_cursor.show()
		var bin_element = BIN_ELEMENT.instantiate() as BinElement
		bin_element.set_id(element).set_texture(available_elements[element].texture)
		bin_element.antivirus = antivirus
		bin_element.spawn_position = terminal.generate_random_position_for_interior()
		bin_element.origin_position = target.global_position
		bin_element.cursor_to_show = duplicated_cursor.duplicate()
		
		terminal.frame_limits.add_child(bin_element)
		duplicated_cursor.hide()
		
		await bin_element.spawned


func pick_random_elements() -> Array[String]:
	var elements = available_elements.duplicate()
	var result: Array[String] = []
	
	for element in range(elements_to_grab):
		var selected = elements.keys().pick_random()
		result.append(selected)
	
	
	return result


func on_finished():
	pass
