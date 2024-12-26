extends PlayerState

func physics_update(delta: float) -> void:
	var new_transform = player.global_transform.looking_at(player.get_global_mouse_position())
	player.global_transform = player.global_transform.interpolate_with(
		new_transform, 10.0 * delta
	)
	
	var move_dir := player.get_move_vector()
	player.apply_central_force(
		move_dir * player.move_speed
	)
	
	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	
	if not move_dir:
		state_machine.transition_to("Idle")
