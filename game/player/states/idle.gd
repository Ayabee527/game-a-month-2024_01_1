extends PlayerState

func physics_update(delta: float) -> void:
	if player.get_move_vector():
		state_machine.transition_to("Move")
	
	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
