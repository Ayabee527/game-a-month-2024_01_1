extends PlayerState

func physics_update(delta: float) -> void:
	if player.get_move_vector():
		state_machine.transition_to("Move")
