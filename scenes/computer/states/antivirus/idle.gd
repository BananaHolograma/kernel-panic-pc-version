class_name BossIdle extends BossState


func _enter():
	if animation_player:
		animation_player.play("idle")
