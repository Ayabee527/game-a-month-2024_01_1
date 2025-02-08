extends BossIState

@export var die_sfx: AudioStreamPlayer2D
@export var anim_player: AnimationPlayer

func enter(_msg:={}) -> void:
	MainCam.target = boss
	MainCam.min_shake_stength = 5.0
	boss.player.toggle_invinc(true)
	
	boss.health_indicator.kill()
	boss.player_tracker.kill()
	boss.coll_shape.set_deferred("disabled", true)
	boss.hurt_coll_shape.set_deferred("disabled", true)
	boss.hit_coll_shape.set_deferred("disabled", true)
	
	boss.boss_music.stop()
	anim_player.play("die")

func squish() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		boss, "global_scale", Vector2.ZERO, 1.6
	)
	tween.tween_property(
		MainCam, "zoom_factor", 1.0, 1.6
	)

func die() -> void:
	MainCam.shake(50.0, 5.0, 2.0)
	boss.set_deferred("freeze", true)
	die_sfx.play()
	
	boss.bleeder.bleed(10, 4.0, 100)
	
	boss.sprite.hide()
	boss.shadow.hide()
	await get_tree().create_timer(2.0, false).timeout
	MainCam.min_shake_stength = 0.0

func defeat() -> void:
	boss.died.emit()
	boss.queue_free()

func drama() -> void:
	var rotate = randf_range(-45, 45)
	while abs(MainCam.rotation_degrees - rotate) < 15:
		rotate = randf_range(-45, 45)
	
	MainCam.rotation_degrees = rotate
	MainCam.flash(Color(1, 1, 1, 0.5), 0.5)
	MainCam.zoom_factor -= (1 - 0.75) / 4.0
	MainCam.shake(40.0, 5.0, 2.0)

func boom() -> void:
	MainCam.flash(Color(1, 1, 1, 0.5), 0.5)
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if "health" in enemy:
			enemy.health.hurt(10000)
		else:
			enemy.queue_free()
	
	MainCam.rotation = 0
	die()
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		MainCam, "zoom_factor", 1.0, 3.5
	).from(0.75)
	await tween.finished
	boss.player.grab_camera()
	boss.player.toggle_invinc(false)
	await get_tree().create_timer(1.0, false).timeout
	RogueHandler.trigger_style(
		boss.player.global_position, "[shake]BOSS ELIMINATED!", 250
	)

func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")


func _on_boss_death_finished() -> void:
	defeat()
