class_name HandRecycleBin extends Attack

const MOVIES = preload("res://ui/themes/classic-95/icons/movies.png")
const MUSIC = preload("res://ui/themes/classic-95/icons/music.png")
const SEARCH = preload("res://ui/themes/classic-95/icons/search.png")
const TEXT_FILE = preload("res://ui/themes/classic-95/icons/text_file.png")
const TEXT_FILE_2 = preload("res://ui/themes/classic-95/icons/text_file_2.png")
const WORLD = preload("res://ui/themes/classic-95/icons/world.png")

const BIN_ELEMENT = preload("res://scenes/computer/attacks/elements/bin_element.tscn")

@export var elements_to_grab := {
	antivirus.PHASES.CALM: 3,
	antivirus.PHASES.ALERT: 4,
	antivirus.PHASES.DANGER: 5,
	antivirus.PHASES.EXTREME: 6
}


var available_elements := {
	"search": {
		"texture": SEARCH,
		"params": {}
	},
	"music": {
		"texture": MUSIC,
		"params": {
			antivirus.PHASES.CALM: {
				"max_speakers_amount": 3,
				"time_active": 3.5
			},
			antivirus.PHASES.ALERT: {
				"max_speakers_amount": 4,
				"time_active": 4.5
			},
			antivirus.PHASES.DANGER: {
				"max_speakers_amount": 5,
				"time_active": 5.0
			},
			antivirus.PHASES.EXTREME: {
				"max_speakers_amount": 6,
				"time_active": 6.0
			},
		}
	},
	"text_file": {
		"texture": [TEXT_FILE, TEXT_FILE_2],
		"params": {
			antivirus.PHASES.CALM: {
				"pulses": 2,
				"angle_step": 30,
				"time_between_pulses": 0.6
			},
			antivirus.PHASES.ALERT: {
				"pulses": 3,
				"angle_step": 25,
				"time_between_pulses": 0.6
			},
			antivirus.PHASES.DANGER: {
				"pulses": 4,
				"angle_step": 20,
				"time_between_pulses": 0.6
			},
			antivirus.PHASES.EXTREME: {
				"pulses": 5,
				"angle_step": 15,
				"time_between_pulses": 0.6
			},
		}
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
	
	for element in pick_random_elements():
		duplicated_cursor.show()
		var bin_element = BIN_ELEMENT.instantiate() as BinElement
		bin_element.set_id(element).set_texture(available_elements[element].texture)
		bin_element.antivirus = antivirus
		
		if available_elements[element].params.keys().size() > 0:
			bin_element.params = available_elements[element]["params"][antivirus.current_phase]
			
		bin_element.spawn_position = terminal.generate_random_position_for_interior()
		bin_element.origin_position = target.global_position
		bin_element.cursor_to_show = duplicated_cursor.duplicate()
		
		terminal.frame_limits.add_child(bin_element)
		duplicated_cursor.hide()
		
		await bin_element.spawned


func pick_random_elements() -> Array[String]:
	var elements = available_elements.duplicate()
	var result: Array[String] = []
	
	for element in range(elements_to_grab[antivirus.current_phase]):
		var selected = elements.keys().pick_random()
		result.append(selected)
	
	
	return result


func on_finished():
	pass
