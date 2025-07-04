extends BossIIState

const PHASES_1: Array[String] = ["R", "G", "B", "Y"]
#const PHASES_2: Array[String] = ["ER", "EG", "EB", "EY"]
const PHASES_2: Array[String] = ["ER"]

var cycle: Array[String] = []

var last_phase: int = 0

func enter(_msg:={}) -> void:
	if last_phase != boss.phase:
		cycle.clear()
	
	if cycle.is_empty():
		if boss.phase == 0:
			cycle = PHASES_1.duplicate()
		else:
			cycle = PHASES_2.duplicate()
		cycle.shuffle()
	
	var next_state = cycle.pop_back()
	if boss.health.health > 0:
		state_machine.transition_to(next_state)
	else:
		state_machine.transition_to("Die")
