extends BossIIState

@export var max_grows: int = 5

@export var grow_timer: Timer
@export var intro_vfx: GPUParticles2D

var grows: int = 0

func enter(_msg:={}) -> void:
	MainCam.target = boss
	MainCam.min_shake_stength = 5.0
	boss.player.toggle_invinc(true)
	boss.boss_music_1.pitch_scale = 0.01
	boss.boss_music_1.play()
	boss.sprite.global_scale = Vector2.ZERO
	boss.shadow.shadow_scale = Vector2.ZERO
	
	#boss.health.hurt(140)
	
	grows = 0
	grow_timer.start()
	
	#var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(
		#boss.boss_music_1, "pitch_scale", 1.0, 3.0
	#).from(0.01)
	#await tween.finished
	#state_machine.transition_to("PhaseSwitch")

func grow() -> void:
	if grows >= max_grows:
		state_machine.transition_to("PhaseSwitch")
	else:
		grows += 1
		MainCam.zoom_factor = lerp(1.0, 0.9, float(grows) / max_grows)
		boss.boss_music_1.pitch_scale = lerp(0.01, 1.0, float(grows) / max_grows)
		
		boss.sprite.global_scale = Vector2.ONE * lerp(0.0, 1.0, float(grows) / max_grows)
		boss.shadow.shadow_scale = Vector2.ONE * lerp(0.0, 1.0, float(grows) / max_grows)
		intro_vfx.restart()
		
		var rotate = randf_range(-45, 45)
		while abs(MainCam.rotation_degrees - rotate) < 10:
			rotate = randf_range(-45, 45)
		
		MainCam.rotation_degrees = rotate
		#MainCam.flash(Color(1, 1, 1, 0.25), 0.3)
		MainCam.shake(40.0, 5.0, 2.0)

func exit() -> void:
	MainCam.rotation_degrees = 0.0
	MainCam.min_shake_stength = 0.0
	boss.player.toggle_invinc(false)
	boss.player.grab_camera()
	boss.hurt_coll_shape.set_deferred("disabled", false)
	grow_timer.stop()
	#boss.linear_damp = 2.0
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		boss.player_tracker, "modulate:a", 1.0, 0.5
	)


func _on_grow_timer_timeout() -> void:
	grow()
