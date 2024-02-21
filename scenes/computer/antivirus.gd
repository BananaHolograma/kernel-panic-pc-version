class_name Antivirus extends CharacterBody2D

signal prepared
signal phase_changed(from: PHASES, to: PHASES)
signal attack_routine_started
signal attack_routine_finished

@export var terminal: MSDosTerminal

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var vfx: AnimatedSprite2D = $VFX
@onready var emotions: AnimatedSprite2D = $Emotions

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
	"button_wave": {
		"repeatable": false,
		"script": ButtonWaveAttack,
		"cursor": cursors.target(),
		"target": get_tree().get_first_node_in_group("player"),
		"phase": {
			PHASES.CALM: {
				"amount": 2,
				"delay_between_spawn": 2.0
			},
			PHASES.ALERT: {
				"amount": 3,
				"delay_between_spawn": 1.5
			},
			PHASES.DANGER: {
				"amount": 5,
				"delay_between_spawn": 1.2
			},
			PHASES.EXTREME: {
				"amount": 7,
				"delay_between_spawn": 1.0
			},
		}
	},
	"rail_shooting": {
		"repeatable": false,
		"script": RailShooting,
		"cursor": cursors.arrow(),
		"target": get_tree().get_first_node_in_group("battleground_rail"),
		"phase": {
			PHASES.CALM: {
				"bullets_per_shoot": 1,
				"shoot_delay": 1.5,
				"time_shooting": 3.0,
			},
			PHASES.ALERT: {
				"bullets_per_shoot": 1,
				"shoot_delay": 1.3,
				"time_shooting": 5.5,
			},
			PHASES.DANGER: {
				"bullets_per_shoot": 1,
				"shoot_delay": 1.2,
				"time_shooting": 7.0,
			},
			PHASES.EXTREME: {
				"bullets_per_shoot": 2,
				"shoot_delay": 1.0,
				"time_shooting": 9.0,
			},
		}
	},
	"hand_recycle_bin": {
		"repeatable": true,
		"script": HandRecycleBin,
		"cursor": cursors.hand(),
		"target": get_tree().get_first_node_in_group("recycle_bin"),
		"phase": {
			PHASES.CALM: {
			},
			PHASES.ALERT: {
			},
			PHASES.DANGER: {
			},
			PHASES.EXTREME: {
			},
		}
	},
	"laser_wheel": {
		"repeatable": false,
		"script": LaserWheel,
		"cursor": null,
		"target": null,
		"phase": {
			PHASES.CALM: {
				"lasers": 1
			},
			PHASES.ALERT: {
				"lasers": 2
			},
			PHASES.DANGER: {
				"lasers": 2
			},
			PHASES.EXTREME: {
				"lasers": 3
			},
		}
	}
}

@onready var delay_between_routines := {
	PHASES.CALM: 2.0,
	PHASES.ALERT: 1.7,
	PHASES.DANGER: 1.5,
	PHASES.EXTREME: 1.0
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
	attack_routine_finished.connect(on_attack_routine_finished)
	

func start_attack_routine():
	await get_tree().create_timer(delay_between_routines[current_phase]).timeout
	
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
		
		if not attack_list[selected].repeatable:
			attack_list.erase(selected)
		
	return attacks


func phase_transition(progress_percentage: float):
	var percentage = progress_percentage * 100
	
	if percentage >= 5 and percentage < 10:
		current_phase = PHASES.ALERT
		
	if percentage >= 10 and percentage < 15:
		current_phase = PHASES.DANGER
		
	if percentage >= 20:
		current_phase = PHASES.EXTREME
		
	
func _number_of_attacks_by_phase(phase: PHASES) -> int:
	match phase:
		PHASES.CALM:
			return 2
		PHASES.ALERT:
			return 3
		PHASES.DANGER:
			return 4
		PHASES.EXTREME:
			return 5
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


func on_phase_changed(_from: PHASES, to: PHASES):
	print("ACTUAL PHASE ", to)
	match to:
		PHASES.ALERT:
			emotions.show()
			emotions.play("exclamation")
			animation_player.play("alert")
		PHASES.DANGER:
			vfx.show()
			vfx.play("aura")
			
			var tween = create_tween()
			tween.tween_property(vfx, "modulate:a", 1.0, 5.0).from(0.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
			tween.finished.connect(func():animation_player.play("danger"))
			
		
func on_antivirus_prepared():
	GameEvents.unlock_player.emit()
	start_attack_routine()


func on_attack_routine_finished():
	start_attack_routine()
	
	if emotions.is_playing():
		emotions.stop()
		emotions.hide()


func on_animation_finished(animation_name: String):
	if animation_name == 'appear':
		animation_player.play("idle")
		_display_cursors()
