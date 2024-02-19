class_name MSDosTerminal extends Node

signal rail_activated
signal rail_ended

enum LIMITS {
	TOP,
	BOTTOM,
	RIGHT,
	LEFT
}


@export var rail_speed := 150.0

@onready var frame_limits: ColorRect = %TerminalLimits
@onready var rail_follow: PathFollow2D = %RailFollow

var rail_object: Node


func _ready():
	rail_follow.rotates = true
	rail_follow.child_entered_tree.connect(
		func(node): 
			rail_object = node
			rail_activated.emit()
	)
	rail_follow.child_exiting_tree.connect(
		func(node): 
			rail_object = null
			rail_ended.emit()
	)


func _physics_process(delta):
	rail_follow.progress += rail_speed * delta
		

func generate_random_position_for_limit(limit: LIMITS) -> Dictionary:
	match limit:
		LIMITS.LEFT:
			return {"limit": limit, "position": Vector2(0, randf_range(0, frame_limits.size.y))}
		LIMITS.RIGHT:
			return {"limit": limit, "position": Vector2(frame_limits.size.x, randf_range(0, frame_limits.size.y))}	
		LIMITS.TOP:
			return {"limit": limit, "position": Vector2(randf_range(0, frame_limits.size.x), 0)}
		LIMITS.BOTTOM:
			return {"limit": limit, "position": Vector2(randf_range(0, frame_limits.size.x), frame_limits.size.y)}
	
	return  {"limit": limit, "position": Vector2.ZERO}
	

func generate_random_limit_position() -> Dictionary:
	var limit = LIMITS.get(LIMITS.keys()[randi() % LIMITS.size()]) as LIMITS
	
	return generate_random_position_for_limit(limit)
