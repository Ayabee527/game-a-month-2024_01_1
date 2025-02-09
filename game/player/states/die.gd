extends PlayerState

@export var die_sfx: AudioStreamPlayer

func enter(_msg:={}) -> void:
	player.grab_camera()
	MainCam.hitstop(0.05, 0.5)
	
	player.set_deferred("freeze", true)
	player.coll_shape.set_deferred("disabled", true)
	player.hurt_coll_shape.set_deferred("disabled", true)
	
	player.sprite.hide()
	player.shadow.hide()
	player.trail.emitting = false
	
	player.health_indicator.kill()
	player.bleeder.bleed(7, 3.0, 100)
	
	MainCam.flash(Color(1, 1, 1, 0.5), 0.5)
	MainCam.shake(70.0, 5.0, 1.0)
	MainCam.min_shake_stength = 5.0
	
	die_sfx.play()
	player.died.emit()
	
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		MainCam, "zoom_factor", 0.75, 3.5
	).from(1.33333)

func physics_update(delta: float) -> void:
	pass


func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")
