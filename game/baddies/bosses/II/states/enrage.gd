extends BossIIState

func enter(_msg:={}) -> void:
	MainCam.shake(40.0, 5.0, 2.0)
	MainCam.flash(Color(1, 1, 1, 0.25), 0.3)
	MainCam.target = boss
	MainCam.min_shake_stength = 5.0
	boss.player.toggle_invinc(true)
	boss.hurt_coll_shape.set_deferred("disabled", true)
	
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		boss.health, "health", boss.health.max_health, 2.0
	)
	tween.tween_property(
		boss.boss_music_1, "pitch_scale", 0.01, 2.0
	)
	
	
	var tween2 = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween2.set_parallel()
	tween2.tween_property(
		boss.sprite, "global_scale", Vector2.ZERO, 2.0
	)
	tween2.tween_property(
		boss.shadow, "shadow_scale", Vector2.ZERO, 2.0
	)
	tween2.tween_property(
		boss.sprite_2, "global_scale", Vector2.ZERO, 2.0
	)
	tween2.tween_property(
		boss.shadow_2, "shadow_scale", Vector2.ZERO, 2.0
	)
	tween2.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(
		boss.sprite, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween2.tween_property(
		boss.shadow, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween2.tween_property(
		boss.sprite_2, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween2.tween_property(
		boss.shadow_2, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween2.set_parallel(false)
	await tween2.finished
	
	boss.sprite.texture = load("res://assets/textures/enemies/smallbossangy2in.png")
	boss.shadow.texture = boss.sprite.texture
	boss.sprite_2.texture = load("res://assets/textures/enemies/smallbossangy2out.png")
	boss.sprite_2.modulate = boss.sprite.modulate
	boss.sprite_2.global_rotation = boss.sprite.global_rotation
	boss.shadow_2.texture = boss.sprite_2.texture
	
	boss.boss_music_2.pitch_scale = 0.01
	boss.boss_music_2.play()
	
	var tween3 = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween3.set_parallel()
	tween3.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween3.tween_property(
		boss.sprite, "global_scale", Vector2.ONE, 2.0
	)
	tween3.tween_property(
		boss.shadow, "shadow_scale", Vector2.ONE, 2.0
	)
	tween3.tween_property(
		boss.sprite_2, "global_scale", Vector2.ONE, 2.0
	)
	tween3.tween_property(
		boss.shadow_2, "shadow_scale", Vector2.ONE, 2.0
	)
	tween3.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween3.tween_property(
		boss.sprite, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween3.tween_property(
		boss.shadow, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween3.tween_property(
		boss.sprite_2, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween3.tween_property(
		boss.shadow_2, "global_rotation_degrees", boss.sprite.global_rotation_degrees * 10, 2.0
	)
	tween3.tween_property(
		boss.boss_music_2, "pitch_scale", 1.0, 2.0
	)
	await tween3.finished
	boss.phase = 1
	state_machine.transition_to("PhaseSwitch")

func exit() -> void:
	MainCam.min_shake_stength = 0.0
	boss.player.toggle_invinc(false)
	boss.player.grab_camera()
	boss.hurt_coll_shape.set_deferred("disabled", false)

func _on_health_was_hurt(new_health: int, amount: int) -> void:
	if is_active or boss.phase == 1:
		return
	
	if boss.health.get_health_percent() <= 50:
		state_machine.transition_to("Enrage")
