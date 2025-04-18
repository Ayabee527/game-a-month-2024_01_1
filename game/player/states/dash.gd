extends PlayerState

@export var dash_particles: GPUParticles2D
@export var dash_timer: Timer
@export var dash_speed: float = 300.0
@export var dash_sound: AudioStreamPlayer

@export var heat_health: Health
@export var heat_indicator: HealthIndicator
@export var cool_timer: Timer

func enter(_msg:={}) -> void:
	player.hurt_coll_shape.set_deferred("disabled", true)
	if not dash_timer.is_stopped():
		if player.get_move_vector():
			state_machine.transition_to("Move")
		else:
			state_machine.transition_to("Idle")
		return
	
	player.linear_velocity = Vector2.ZERO
	player.dashing = true
	player.linear_damp = 0.75
	var move_dir: Vector2 = (
		player.get_move_vector() if player.get_move_vector() else Vector2.RIGHT
	)
	
	player.apply_central_impulse(
		move_dir * dash_speed
	)
	dash_timer.start()
	dash_particles.look_at(
		player.global_position + move_dir
	)
	dash_sound.play()
	dash_particles.restart()
	MainCam.shake(20.0, 10.0, 5.0)
	player.look_at(player.global_position + move_dir)
	player.sprite.squish(
		0.5, 5.0, false, true
	)
	heat_health.hurt(25)
	cool_timer.stop()
	
	player.weapon_handler.firing = false
	MainCam.min_shake_stength = 3.0

func physics_update(delta: float) -> void:
	if dash_timer.is_stopped():
		var new_transform = player.global_transform.looking_at(player.get_global_mouse_position())
		player.global_transform = player.global_transform.interpolate_with(
			new_transform, 10.0 * delta
		)
	
	var move_dir := player.get_move_vector()
	player.apply_central_force(
		move_dir * player.move_speed * 1.5
	)
	
	if not move_dir and dash_timer.is_stopped():
		state_machine.transition_to("Idle")
	
	if Input.is_action_just_released("dash") and dash_timer.is_stopped():
		if move_dir:
			state_machine.transition_to("Move")
		else:
			state_machine.transition_to("Idle")

func exit() -> void:
	if not player.is_invinc:
		player.hurt_coll_shape.set_deferred("disabled", false)
	player.dashing = false
	player.linear_damp = 2.5
	MainCam.min_shake_stength = 0.0
	cool_timer.start()

func _on_dash_timer_timeout() -> void:
	if not player.is_invinc:
		player.hurt_coll_shape.set_deferred("disabled", false)
	player.linear_damp = 2.5
	
	if not Input.is_action_pressed("dash"):
		if player.get_move_vector():
			state_machine.transition_to("Move")
		else:
			state_machine.transition_to("Idle")
	
	if Input.is_action_pressed("left_click"):
		await get_tree().create_timer(0.1, false).timeout
		player.weapon_handler.firing = true


func _on_dodge_check_hurt(_hitbox: Hitbox, _damage: int, _invinc_time: float) -> void:
	if not dash_timer.is_stopped():
		if dash_timer.time_left >= 0.6 * dash_timer.wait_time:
			RogueHandler.trigger_style(
				player.global_position, "PERFECT DODGE!", 15
			)
		else:
			RogueHandler.trigger_style(
				player.global_position, "DODGE!", 5
			)


func _on_cool_timer_timeout() -> void:
	heat_health.heal(1)
	if heat_health.health >= 100 and player.overheated:
		player.overheated = false


func _on_heat_health_health_changed(new_health: int) -> void:
	heat_indicator.update_health(new_health, heat_health.max_health)


func _on_heat_health_has_died() -> void:
	MainCam.shake(75.0, 5.0, 5.0)
	player.overheated = true
	player.health.hurt(1)
