class_name GameCamera extends Camera2D

@onready var shake_camera_component_2d: ShakeCameraComponent2D = $ShakeCameraComponent2D



func shake():
	shake_camera_component_2d.shake()
