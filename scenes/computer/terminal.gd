class_name MSDosTerminal extends Node

enum LIMITS {
	TOP,
	BOTTOM,
	RIGHT,
	LEFT
}


@onready var frame_limits: ColorRect = %TerminalLimits



func generate_random_position_for_interior() -> Vector2:
	return Vector2(randf_range(0, frame_limits.size.x), randf_range(0, frame_limits.size.y))


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
