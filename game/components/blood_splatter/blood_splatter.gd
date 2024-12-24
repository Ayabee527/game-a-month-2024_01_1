class_name BloodSplatter
extends GPUParticles2D


func _on_finished() -> void:
	queue_free()
