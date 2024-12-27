extends BossIState

func enter(_msg:={}) -> void:
	MainCam.target = boss
	MainCam.min_shake_stength = 5.0
	boss.player.toggle_invinc(true)
	boss.boss_music.play()
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		boss, "global_scale", Vector2.ONE, 3.0
	).from(Vector2.ZERO)
	tween.tween_property(
		MainCam, "zoom_factor", 0.75, 3.0
	)
	tween.tween_property(
		boss.boss_music, "pitch_scale", 1.0, 3.0
	).from(0.01)
	await tween.finished
	state_machine.transition_to("PhaseSwitch")

func exit() -> void:
	MainCam.min_shake_stength = 0.0
	boss.player.toggle_invinc(false)
	boss.player.grab_camera()
	boss.hurt_coll_shape.set_deferred("disabled", false)
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		boss.player_tracker, "modulate:a", 1.0, 0.5
	)
