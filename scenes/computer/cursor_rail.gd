class_name CursorRail extends Path2D

signal rail_activated
signal rail_ended


@onready var rail_follow: PathFollow2D = %RailFollow
@onready var player: Player = get_tree().get_first_node_in_group("player")

var rail_object: Node
var rail_speed := 150.0


func _ready():
	rail_follow.rotates = true
	rail_follow.child_entered_tree.connect(
		func(node): 
			rail_object = node
			rail_activated.emit()
	)
	rail_follow.child_exiting_tree.connect(
		func(_node): 
			rail_object = null
			rail_ended.emit()
	)


func _physics_process(delta):
	rail_follow.progress += rail_speed * delta
		
