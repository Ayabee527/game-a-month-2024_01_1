extends PlayerState

func physics_update(delta: float) -> void:
	var new_transform = player.global_transform.looking_at(player.get_global_mouse_position())
	player.global_transform = player.global_transform.interpolate_with(
		new_transform, 10.0 * delta
	)
	
	if player.get_move_vector():
		state_machine.transition_to("Move")
	
	if Input.is_action_just_pressed("dash") and not player.overheated:
		state_machine.transition_to("Dash")
