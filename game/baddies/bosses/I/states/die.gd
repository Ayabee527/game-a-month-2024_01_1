extends BossIState

@export var die_sfx: AudioStreamPlayer2D

func enter(_msg:={}) -> void:
	MainCam.target = boss
	MainCam.min_shake_stength = 5.0
	boss.player.toggle_invinc(true)
	
	boss.health_indicator.kill()
	boss.player_tracker.kill()
	boss.coll_shape.set_deferred("disabled", true)
	boss.hurt_coll_shape.set_deferred("disabled", true)
	boss.hit_coll_shape.set_deferred("disabled", true)
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		boss, "global_scale", Vector2.ZERO, 3.0
	)
	tween.tween_property(
		MainCam, "zoom_factor", 1.0, 3.0
	)
	tween.tween_property(
		boss.boss_music, "pitch_scale", 0.01, 3.0
	)
	await tween.finished
	boss.boss_music.stop()
	die()

func die() -> void:
	MainCam.shake(50.0, 5.0, 2.0)
	boss.set_deferred("freeze", true)
	die_sfx.play()
	
	boss.bleeder.bleed(10, 4.0, 100)
	
	var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW]
	for i: int in range(50):
		boss.pointer.blood_color = colors.pick_random()
		boss.pointer.bleed(1, 200.0, 600.0, 10.0)
	
	boss.sprite.hide()
	boss.shadow.hide()
	await get_tree().create_timer(4.0, false).timeout
	MainCam.min_shake_stength = 0.0
	boss.player.grab_camera()
	boss.player.toggle_invinc(false)
	boss.died.emit()
	boss.queue_free()

func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")
