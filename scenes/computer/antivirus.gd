class_name Antivirus extends CharacterBody2D

signal prepared
signal phase_changed(from: PHASES, to: PHASES)
signal attack_routine_started
signal attack_routine_finished

@export var terminal: MSDosTerminal

@onready var cursors: CursorsOrbit = %Cursors
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx: AudioStreamPlayer = $SFX

const SERAPHIM_VOICE_6 = preload("res://assets/sounds/Seraphim_Voice6.wav")
const HOLY_APPEAR = preload("res://assets/sounds/holy_appear.ogg")


enum PHASES {
	CALM,
	ALERT,
	DANGER,
	EXTREME
}

@onready var available_attacks := {
	#"button_wave": {
		#"script": ButtonWaveAttack,
		#"cursor": cursors.target(),
		#"target": get_tree().get_first_node_in_group("player"),
		#"phase": {
			#PHASES.CALM: {
				#"amount": 30,
				#"delay_between_spawn": 1.1
			#},
			#PHASES.ALERT: {
				#"amount": 45,
				#"delay_between_spawn": 1.0
			#},
			#PHASES.DANGER: {
				#"amount": 50,
				#"delay_between_spawn": 0.9
			#},
			#PHASES.EXTREME: {
				#"amount": 60,
				#"delay_between_spawn": 0.7
			#},
		#}
	#},
	#"rail_shooting": {
		#"script": RailShooting,
		#"cursor": cursors.arrow(),
		#"target": get_tree().get_first_node_in_group("battleground_rail"),
		#"phase": {
			#PHASES.CALM: {
				#"bullets_per_shoot": 2,
				#"shoot_delay": 1.2,
				#"time_shooting": 10.0,
			#},
			#PHASES.ALERT: {
				#"bullets_per_shoot": 4,
				#"shoot_delay": 1,
				#"time_shooting": 15.0,
			#},
			#PHASES.DANGER: {
				#"bullets_per_shoot": 6,
				#"shoot_delay": 0.8,
				#"time_shooting": 20.0,
			#},
			#PHASES.EXTREME: {
				#"bullets_per_shoot": 10,
				#"shoot_delay": 0.5,
				#"time_shooting": 30.0,
			#},
		#}
	#},
	"hand_recycle_bin": {
		"script": HandRecycleBin,
		"cursor": cursors.hand(),
		"target": get_tree().get_first_node_in_group("recycle_bin"),
		"phase": {
			PHASES.CALM: {
				"elements_to_grab": 3
			},
			PHASES.ALERT: {
				"elements_to_grab": 4
			},
			PHASES.DANGER: {
				"elements_to_grab": 5
			},
			PHASES.EXTREME: {
				"elements_to_grab": 6
			},
		}
	}
}

var current_phase := PHASES.CALM:
	set(value):
		if value != current_phase:
			phase_changed.emit(current_phase, value)
		
		current_phase = value

var remaining_attacks := 0:
	set(value):
		remaining_attacks = value
		
		if value == 0:
			attack_routine_finished.emit()


func _ready():
	animation_player.animation_finished.connect(on_animation_finished)
	animation_player.play("appear")
	
	prepared.connect(on_antivirus_prepared)
	phase_changed.connect(on_phase_changed)
	

func start_attack_routine():
	var attacks = select_attacks()
	
	remaining_attacks = attacks.size()
	
	attack_routine_started.emit()
	
	for attack in attacks:
		var script = attack.script.new() as Attack
		var phase = attack["phase"][current_phase]

		script.with_terminal(terminal).with_antivirus(self)
		
		if attack.target:
			script.with_target(attack.target)
			
		if attack.cursor is Cursor:
			script.with_cursor(attack.cursor)
		
		for property in phase.keys():	
			script[property] = phase[property]
			
		add_child(script)
		script.finished.connect(func(): remaining_attacks -= 1)
		script.start()
	

func select_attacks() -> Array:
	var number_of_attacks := _number_of_attacks_by_phase(current_phase)
	var attack_list = available_attacks.duplicate()
	var attacks := []
	
	for i in range(number_of_attacks):
		var selected = attack_list.keys().pick_random()

		attacks.append(attack_list[selected])
		attack_list.erase(selected)
		
	return attacks


func phase_transition(progress_percentage: float):
	if progress_percentage >= 15 and progress_percentage < 50:
		current_phase = PHASES.ALERT
		
	if progress_percentage >= 50  and progress_percentage < 85:
		current_phase = PHASES.DANGER
		
	if progress_percentage >= 85:
		current_phase = PHASES.EXTREME
		
	
func _number_of_attacks_by_phase(phase: PHASES) -> int:
	match phase:
		PHASES.CALM:
			return 1
		PHASES.ALERT:
			return 2
		PHASES.DANGER:
			return 3
		PHASES.EXTREME:
			return 4
		_:
			return 1


func _display_cursors(delay_between: float = 1.0):
	for cursor_idx in range(cursors.get_child_count()):
		cursors.display_cursor(cursor_idx)
		await get_tree().create_timer(delay_between).timeout
		
	prepared.emit()


func _holy_appear():
	## TEMPORARY
	var sfx2 = AudioStreamPlayer.new()
	sfx2.stream = HOLY_APPEAR
	sfx.bus = "SFX"
	add_child(sfx2)

	sfx2.finished.connect(
		func(): 
		sfx2.queue_free()
		sfx.stream = SERAPHIM_VOICE_6
		sfx.volume_db = linear_to_db(0.8)
		sfx.play()
	)
	sfx2.play()


func on_animation_finished(animation_name: String):
	if animation_name == 'appear':
		animation_player.play("idle")
		_display_cursors()


## TODO - ANIMATIONS TO REFLECT THE PHASE CHANGE IN THE BATTLEGROUND
func on_phase_changed(from: PHASES, to: PHASES):
	pass
	
	
func on_antivirus_prepared():
	GameEvents.unlock_player.emit()
	start_attack_routine()

