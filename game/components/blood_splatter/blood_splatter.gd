class_name BloodSplatter
extends GPUParticles2D

func _ready() -> void:
	if UpgradeHandler.blood_fade_time > 0:
		speed_scale = 10.0 / UpgradeHandler.blood_fade_time
	else:
		return
		await get_tree().create_timer(lifetime / 2.0, false).timeout
		speed_scale = 0.0

func _on_finished() -> void:
	queue_free()
