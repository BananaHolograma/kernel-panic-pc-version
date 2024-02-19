class_name CursorRail extends Path2D

@onready var rail_follow: PathFollow2D = %RailFollow
@onready var player: Player = get_tree().get_first_node_in_group("player")

var cursor: Sprite2D

var speed := 150.0


func _ready():
	rail_follow.rotates = true
	rail_follow.child_entered_tree.connect(func(node): cursor = node)
	rail_follow.child_exiting_tree.connect(func(node): cursor = null)


func _physics_process(delta):
	rail_follow.progress += speed * delta
		
